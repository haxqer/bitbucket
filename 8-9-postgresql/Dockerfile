# syntax=docker/dockerfile:1.4
FROM eclipse-temurin:11-jdk-jammy AS builder

ARG BITBUCKET_VERSION=8.9.19
ARG BITBUCKET_PRODUCT=bitbucket-software
ARG AGENT_VERSION=1.3.3
ARG GIT_VERSION=2.42.0

# Install build dependencies and Git
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install -y curl make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev gettext unzip zip

# Build Git
RUN curl -sL https://github.com/git/git/archive/v${GIT_VERSION}.zip -o git.zip && \
    unzip git.zip && \
    cd git-* && \
    make prefix=/usr/local all && \
    make prefix=/usr/local install && \
    cd .. && \
    rm -rf git-* git.zip

# Install Git LFS
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y git-lfs && \
    git lfs install --system

# Download and prepare Bitbucket files
RUN mkdir -p /opt/bitbucket /var/bitbucket /var/agent && \
    curl -fLo /var/agent/atlassian-agent.jar https://bamboo.hosttweb.com/artifact/AA-AA/JOB1/build-46/jar/atlassian-agent-jar-with-dependencies.jar && \
    curl -fLo /tmp/atlassian.tar.gz https://product-downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz && \
    tar xzf /tmp/atlassian.tar.gz -C /opt/bitbucket/ --strip-components 1 && \
    rm -f /tmp/atlassian.tar.gz

# Final stage
FROM eclipse-temurin:11-jdk-jammy

LABEL maintainer="haxqer <haxqer666@gmail.com>" version="8.9.19"

ENV BITBUCKET_USER=bitbucket \
    BITBUCKET_GROUP=bitbucket \
    BITBUCKET_HOME=/var/bitbucket \
    BITBUCKET_INSTALL=/opt/bitbucket \
    JVM_MINIMUM_MEMORY=2g \
    JVM_MAXIMUM_MEMORY=6g \
    JVM_CODE_CACHE_ARGS='-XX:InitialCodeCacheSize=1g -XX:ReservedCodeCacheSize=2g' \
    AGENT_PATH=/var/agent \
    AGENT_FILENAME=atlassian-agent.jar

ENV JAVA_OPTS="-javaagent:${AGENT_PATH}/${AGENT_FILENAME} ${JVM_CODE_CACHE_ARGS} -Dbitbucket.home=${BITBUCKET_HOME}"
ENV OPENSEARCH_JAVA_OPTS="${JAVA_OPTS}"

# Copy built artifacts from builder stage
COPY --from=builder /usr/local/bin/git* /usr/local/bin/
COPY --from=builder /usr/local/libexec/git-core /usr/local/libexec/git-core
COPY --from=builder /opt/bitbucket ${BITBUCKET_INSTALL}
COPY --from=builder /var/agent ${AGENT_PATH}

RUN apt-get update && \
    apt-get install -y --no-install-recommends git-lfs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r ${BITBUCKET_GROUP} && \
    useradd -r -g ${BITBUCKET_GROUP} ${BITBUCKET_USER} && \
    git lfs install --system && \
    mkdir -p ${BITBUCKET_HOME} && \
    chown -R ${BITBUCKET_USER}:${BITBUCKET_GROUP} ${BITBUCKET_INSTALL} ${BITBUCKET_HOME} ${AGENT_PATH}

VOLUME ${BITBUCKET_HOME}
USER ${BITBUCKET_USER}
WORKDIR ${BITBUCKET_INSTALL}
EXPOSE 7990 7999

ENTRYPOINT ["/opt/bitbucket/bin/start-bitbucket.sh", "-fg"]