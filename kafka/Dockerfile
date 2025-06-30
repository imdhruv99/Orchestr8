FROM imdhruv99/golden-ubuntu:1.0.0

USER root

ENV KAFKA_VERSION=3.9.0
ENV SCALA_VERSION=2.13
ENV KAFKA_ROOT=/opt
ENV KAFKA_HOME=/opt/kafka
ENV JMX_EXPORTER_VERSION=0.20.0
# Install OpenJDK, curl, and minimal tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    curl \
    bash \
    tini && \
    rm -rf /var/lib/apt/lists/*

# Add kafka user and group
RUN groupadd -r kafka && useradd -r -g kafka -d /var/lib/kafka -s /sbin/nologin kafka

# Download and install Kafka
RUN curl -sL "https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz" | tar -xz -C /opt/ && \
    mv /opt/kafka_$SCALA_VERSION-$KAFKA_VERSION /opt/kafka && \
    mkdir -p /var/lib/kafka/data && \
    chown -R kafka:kafka /opt/kafka /var/lib/kafka

# JMX Exporter
RUN mkdir -p /opt/jmx-exporter && \
    curl -sL "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar" -o /opt/jmx-exporter/jmx_prometheus_javaagent.jar

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && chown kafka:kafka /docker-entrypoint.sh

# Expose Kafka and JMX ports
EXPOSE 19091 19092 19093 9999

USER kafka
WORKDIR /var/lib/kafka

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/opt/kafka/bin/kafka-server-start.sh", "/opt/kafka/config/server.properties"]
