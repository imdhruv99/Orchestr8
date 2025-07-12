FROM imdhruv99/golden-ubuntu:1.0.0

LABEL maintainer="Dhruv Prajapati"
LABEL description="Production ready Apache Kafka with KRaft mode"

# Environment variables
ENV KAFKA_VERSION=3.9.0
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/opt/kafka
ENV KAFKA_DATA_DIR=/var/lib/kafka/data
ENV KAFKA_LOG_DIR=/var/lib/kafka/logs
ENV JMX_EXPORTER_VERSION=0.20.0
ENV PATH="${KAFKA_HOME}/bin:$PATH"

# Switch to root user for privileged operations
USER root

# Create kafka user and group
RUN groupadd -r kafka && \
    useradd -r -g kafka -d ${KAFKA_HOME} -s /bin/bash kafka && \
    mkdir -p ${KAFKA_DATA_DIR} ${KAFKA_LOG_DIR} && \
    chown -R kafka:kafka ${KAFKA_DATA_DIR} ${KAFKA_LOG_DIR}

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    wget \
    gnupg2 \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install Kafka
RUN wget -q https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -O /tmp/kafka.tgz && \
    tar -xzf /tmp/kafka.tgz -C /opt && \
    ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} && \
    rm /tmp/kafka.tgz

# Download JMX Exporter
RUN wget -q https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar -O /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/jmx_prometheus_javaagent.jar

# Copy configuration files
COPY configs/jmx-config.yml /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/jmx-config.yml
COPY docker-entrypoint.sh /usr/local/bin/

# Set proper permissions after Kafka is installed and symlinked
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown -R kafka:kafka /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} && \
    chmod 755 /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/bin/*.sh && \
    chown -R kafka:kafka ${KAFKA_DATA_DIR} ${KAFKA_LOG_DIR}

# Create necessary directories with proper permissions
RUN mkdir -p /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/logs && \
    chown -R kafka:kafka /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}/logs

# Switch to kafka user and working directory
USER kafka
WORKDIR ${KAFKA_HOME}

# Expose ports
EXPOSE 9092 9093 9999

# Create volumes for persistent data
VOLUME [ "${KAFKA_DATA_DIR}", "${KAFKA_LOG_DIR}" ]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD kafka-topics.sh --bootstrap-server localhost:9092 --list || exit 1

# Entrypoint
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "kafka-server-start.sh", "config/server.properties" ]
