FROM imdhruv99/golden-ubuntu:1.0.0

LABEL maintainer="Dhruv Prajapati"
LABEL description="Production ready Apache Zookeeper"

# Environment variables
ENV ZOOKEEPER_VERSION=3.9.1
ENV ZOOKEEPER_HOME=/opt/zookeeper
ENV ZOOKEEPER_DATA_DIR=/var/lib/zookeeper/data
ENV ZOOKEEPER_LOG_DIR=/var/lib/zookeeper/logs
ENV PATH="${ZOOKEEPER_HOME}/bin:$PATH"
ENV JMX_EXPORTER_VERSION=0.20.0

# Switch to root user for privileged operations
USER root

# Create zookeeper user and group
RUN groupadd -r zookeeper && \
    useradd -r -g zookeeper -d ${ZOOKEEPER_HOME} -s /bin/bash zookeeper && \
    mkdir -p ${ZOOKEEPER_DATA_DIR} ${ZOOKEEPER_LOG_DIR} && \
    chown -R zookeeper:zookeeper ${ZOOKEEPER_DATA_DIR} ${ZOOKEEPER_LOG_DIR}

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    wget \
    gnupg2 \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install Zookeeper
RUN wget -q https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz -O /tmp/zookeeper.tar.gz && \
    tar -xzf /tmp/zookeeper.tar.gz -C /opt && \
    ln -s /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin ${ZOOKEEPER_HOME} && \
    rm /tmp/zookeeper.tar.gz

# Download JMX Exporter
RUN wget -q https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar -O /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin/jmx_prometheus_javaagent.jar

# Copy configuration files
COPY configs/jmx-config.yml /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin/jmx-config.yml
COPY docker-entrypoint.sh /usr/local/bin/

# Set proper permissions after Zookeeper is installed and symlinked
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown -R zookeeper:zookeeper /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin && \
    chmod 755 /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin/bin/*.sh && \
    chown -R zookeeper:zookeeper ${ZOOKEEPER_DATA_DIR} ${ZOOKEEPER_LOG_DIR}

# Create necessary directories with proper permissions
RUN mkdir -p /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin/logs && \
    chown -R zookeeper:zookeeper /opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin/logs

# Switch to zookeeper user and working directory
USER zookeeper
WORKDIR ${ZOOKEEPER_HOME}

# Expose ports
EXPOSE 2181 2888 3888 9999

# Create volumes for persistent data
VOLUME [ "${ZOOKEEPER_DATA_DIR}", "${ZOOKEEPER_LOG_DIR}" ]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD echo ruok | nc localhost 2181 | grep imok || exit 1

# Entrypoint
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "zkServer.sh", "start-foreground" ]
