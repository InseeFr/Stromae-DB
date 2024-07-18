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

HEALTHCHECK CMD [ "java", \
  "org.exist.start.Main", "client", \
  "--no-gui",  \
  "--user", "guest", "--password", "guest", \
  "--xpath", "system:get-version()" ]

ENTRYPOINT [ "java", \
  "org.exist.start.Main"]
CMD ["jetty" ]