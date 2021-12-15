FROM existdb/existdb:5.3.1

EXPOSE 8080 8443

COPY conf/conf.xml /exist/etc
COPY restxq/build/*.xar /exist/autodeploy
COPY WS/build/*.xar /exist/autodeploy
COPY apps/orbeon/build/*.xar /exist/autodeploy
