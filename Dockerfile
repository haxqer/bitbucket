FROM haxqer/jdk:8-git-python

LABEL maintainer="haxqer <haxqer666@gmail.com>" version="7.21.16"

ARG BITBUCKET_VERSION=7.21.16
ARG BITBUCKET_PRODUCT=bitbucket-software
ARG AGENT_VERSION=1.3.3
ARG MYSQL_DRIVER_VERSION=8.0.22

ENV BITBUCKET_USER=bitbucket \
    BITBUCKET_GROUP=bitbucket \
    BITBUCKET_HOME=/var/bitbucket \
    BITBUCKET_INSTALL=/opt/bitbucket \
    JVM_MINIMUM_MEMORY=2g \
    JVM_MAXIMUM_MEMORY=6g \
    JVM_CODE_CACHE_ARGS='-XX:InitialCodeCacheSize=2g -XX:ReservedCodeCacheSize=6g' \
    AGENT_PATH=/var/agent \
    AGENT_FILENAME=atlassian-agent.jar

ENV JAVA_OPTS="-javaagent:${AGENT_PATH}/${AGENT_FILENAME} ${JAVA_OPTS}"

RUN mkdir -p ${BITBUCKET_INSTALL} ${BITBUCKET_HOME} ${AGENT_PATH} \
&& curl -o ${AGENT_PATH}/${AGENT_FILENAME}  https://github.com/haxqer/jira/releases/download/v${AGENT_VERSION}/atlassian-agent.jar -L \
&& curl -o /tmp/atlassian.tar.gz https://product-downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz -L \
&& tar xzf /tmp/atlassian.tar.gz -C ${BITBUCKET_INSTALL}/ --strip-components 1 \
&& rm -f /tmp/atlassian.tar.gz \
&& curl -o ${BITBUCKET_INSTALL}/app/WEB-INF/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar -L

RUN export CONTAINER_USER=$BITBUCKET_USER \
&& export CONTAINER_GROUP=$BITBUCKET_GROUP \
&& groupadd -r $BITBUCKET_GROUP && useradd -r -g $BITBUCKET_GROUP $BITBUCKET_USER \
&& chown -R $BITBUCKET_USER:$BITBUCKET_GROUP ${BITBUCKET_INSTALL} ${BITBUCKET_HOME}/ ${AGENT_PATH}

VOLUME $BITBUCKET_HOME
USER $BITBUCKET_USER
WORKDIR $BITBUCKET_INSTALL
EXPOSE 7990
EXPOSE 7999

ENTRYPOINT ["/opt/bitbucket/bin/start-bitbucket.sh", "-fg"]