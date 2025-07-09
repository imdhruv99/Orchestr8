FROM imdhruv99/golden-ubuntu:1.0.0

LABEL maintainer="Dhruv Prajapati"
LABEL description="Production ready Apache Storm"

# Environment
ENV STORM_VERSION=2.8.1
ENV STORM_HOME=/opt/storm
ENV STORM_LOG_DIR=/var/log/storm
ENV JMX_EXPORTER_VERSION=0.20.0
ENV PATH="${STORM_HOME}/bin:$PATH"

# Switch to root for privileged operations
USER root

# Create storm user and group
RUN groupadd -r storm && \
    useradd -r -g storm -d ${STORM_HOME} -s /bin/bash storm && \
    mkdir -p ${STORM_HOME} ${STORM_LOG_DIR} && \
    chown -R storm:storm ${STORM_HOME} ${STORM_LOG_DIR}

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    wget \
    ca-certificates \
    netcat \
    gnupg2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Storm
RUN wget -q https://downloads.apache.org/storm/apache-storm-${STORM_VERSION}/apache-storm-${STORM_VERSION}.tar.gz -O /tmp/storm.tar.gz && \
    tar -tzf /tmp/storm.tar.gz | head && \
    tar -xzf /tmp/storm.tar.gz -C /opt && \
    ln -s /opt/apache-storm-${STORM_VERSION} ${STORM_HOME} && \
    rm /tmp/storm.tar.gz

# Download JMX Exporter
RUN wget -q https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar -O ${STORM_HOME}/jmx_prometheus_javaagent.jar

# Copy entrypoint and configs
COPY docker-entrypoint.sh /usr/local/bin/
COPY configs/jmx-config.yml ${STORM_HOME}/jmx-config.yml

# Set permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown -R storm:storm /opt/apache-storm-${STORM_VERSION} && \
    find /opt/apache-storm-${STORM_VERSION}/bin -type f -name "*.sh" -exec chmod 755 {} +

# Expose required ports
EXPOSE 6627 6700 6701 6702 6703 8080 9999

# Volumes
VOLUME [ "${STORM_LOG_DIR}" ]

# Switch to storm user
USER storm
WORKDIR ${STORM_HOME}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD bash -c 'timeout 5 bash -c "echo getClusterInfo | nc localhost 6627" || exit 1'

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "nimbus" ]
