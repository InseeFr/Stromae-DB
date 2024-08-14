FROM existdb/existdb:6.2.0 AS exist-db
FROM maven:3.9.4-eclipse-temurin-8-focal AS builder

## Add zip and unzip command
RUN apt-get update && \
  apt-get install zip unzip jq -y

## Add exist lib
COPY --from=exist-db /exist/lib /exist/lib
RUN unzip -q -o /exist/lib/exist.uber.jar -d /exist/lib/
# Delete jar
RUN rm -rf /exist/lib/exist.uber.jar

## Add exist lib
COPY content /build-exist
# add new libs
RUN cd /build-exist && mvn package
RUN unzip -q -o /build-exist/target/\*.jar -d /exist/lib/
# Delete jar
RUN rm -rf /exist/lib/*.jar

# Make final exist jar without CVE
RUN cd /exist/lib && zip -q -m -r exist.uber.jar *


FROM eclipse-temurin:8u392-b08-jre-jammy

# For next lines, inspired by
# # https://github.com/eXist-db/exist/blob/develop-6.x.x/exist-docker/src/main/resources-filtered/Dockerfile

## Add other exist dependencies from exist-db
COPY --from=exist-db /exist/LICENSE /exist/LICENSE
COPY --from=exist-db /exist/etc /exist/etc
COPY --from=exist-db /exist/logs /exist/logs

## Add exist-db apps:
COPY --from=exist-db /exist/autodeploy/* /exist/autodeploy/

## Add custom configuration
COPY --from=builder /exist/lib /exist/lib
COPY --from=builder /build-exist/target/*.xar /exist/autodeploy/
COPY --from=builder /build-exist/conf/conf.xml /exist/etc/conf.xml

EXPOSE 8080 8443

ARG CACHE_MEM
ARG MAX_BROKER
ARG JVM_MAX_RAM_PERCENTAGE

ENV EXIST_HOME "/exist"
ENV CLASSPATH=/exist/lib/exist.uber.jar

ENV JAVA_TOOL_OPTIONS \
  -Dfile.encoding=UTF8 \
  -Dsun.jnu.encoding=UTF-8 \
  -Djava.awt.headless=true \
  -Dorg.exist.db-connection.cacheSize=${CACHE_MEM:-256}M \
  -Dorg.exist.db-connection.pool.max=${MAX_BROKER:-20} \
  -Dlog4j.configurationFile=/exist/etc/log4j2.xml \
  -Dexist.home=/exist \
  -Dexist.configurationFile=/exist/etc/conf.xml \
  -Djetty.home=/exist \
  -Dexist.jetty.config=/exist/etc/jetty/standard.enabled-jetty-configs \
  -XX:+UseG1GC \
  -XX:+UseStringDeduplication \
  -XX:+UseContainerSupport \
  -XX:MaxRAMPercentage=${JVM_MAX_RAM_PERCENTAGE:-75.0} \
  -XX:+ExitOnOutOfMemoryError


ENV JAVA_USER_ID=10001
ENV JAVA_USER=java
RUN groupadd -g $JAVA_USER_ID $JAVA_USER && \
  useradd -r -u $JAVA_USER_ID -g $JAVA_USER $JAVA_USER

# Give write access to exist folder (inside external volume)
ENV EXIST_DATA_FOLDER=/exist/data
ENV EXIST_DB_FOLDER=/db
ENV EXIST_LOG_FOLDER=/exist/logs

RUN mkdir -p $EXIST_DATA_FOLDER && \
  chown -R $JAVA_USER_ID:$JAVA_USER_ID $EXIST_DATA_FOLDER && \
  chmod -R 755 $EXIST_DATA_FOLDER

RUN mkdir -p $EXIST_LOG_FOLDER && \
  chown -R $JAVA_USER_ID:$JAVA_USER_ID $EXIST_LOG_FOLDER && \
  chmod -R 755 $EXIST_LOG_FOLDER

RUN mkdir $EXIST_DB_FOLDER && \
  chown -R $JAVA_USER_ID:$JAVA_USER_ID $EXIST_DB_FOLDER && \
  chmod -R 755 $EXIST_DB_FOLDER

USER $JAVA_USER_ID

HEALTHCHECK CMD [ "java", \
  "org.exist.start.Main", "client", \
  "--no-gui",  \
  "--user", "guest", "--password", "guest", \
  "--xpath", "system:get-version()" ]

ENTRYPOINT [ "java", \
  "org.exist.start.Main"]
CMD ["jetty" ]