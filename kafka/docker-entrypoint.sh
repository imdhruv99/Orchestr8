#!/bin/bash
set -e

# Function to replace environment variables in server.properties
configure_kafka() {
    echo "Configuring Kafka server.properties..."

    # Create a temporary file for processing
    cp ${KAFKA_HOME}/config/server.properties ${KAFKA_HOME}/config/server.properties.tmp

    # Replace key configurations with environment variables if provided
    if [ ! -z "$KAFKA_NODE_ID" ]; then
        sed -i "s/node.id=1/node.id=$KAFKA_NODE_ID/g" ${KAFKA_HOME}/config/server.properties.tmp
    fi

    if [ ! -z "$KAFKA_CONTROLLER_QUORUM_VOTERS" ]; then
        sed -i "s|controller.quorum.voters=1@localhost:9093|controller.quorum.voters=$KAFKA_CONTROLLER_QUORUM_VOTERS|g" ${KAFKA_HOME}/config/server.properties.tmp
    fi

    if [ ! -z "$KAFKA_LISTENERS" ]; then
        sed -i "s|listeners=PLAINTEXT://:9092,CONTROLLER://:9093|listeners=$KAFKA_LISTENERS|g" ${KAFKA_HOME}/config/server.properties.tmp
    fi

    if [ ! -z "$KAFKA_ADVERTISED_LISTENERS" ]; then
        sed -i "s|advertised.listeners=PLAINTEXT://localhost:9092|advertised.listeners=$KAFKA_ADVERTISED_LISTENERS|g" ${KAFKA_HOME}/config/server.properties.tmp
    fi

    if [ ! -z "$KAFKA_LOG_DIRS" ]; then
        sed -i "s|log.dirs=/var/lib/kafka/logs|log.dirs=$KAFKA_LOG_DIRS|g" ${KAFKA_HOME}/config/server.properties.tmp
    fi

    if [ ! -z "$KAFKA_NUM_PARTITIONS" ]; then
        sed -i "s/num.partitions=3/num.partitions=$KAFKA_NUM_PARTITIONS/g" ${KAFKA_HOME}/config/server.properties.tmp
    fi

    if [ ! -z "$KAFKA_LOG_RETENTION_HOURS" ]; then
        sed -i "s/log.retention.hours=168/log.retention.hours=$KAFKA_LOG_RETENTION_HOURS/g" ${KAFKA_HOME}/config/server.properties.tmp
    fi

    if [ ! -z "$KAFKA_DEFAULT_REPLICATION_FACTOR" ]; then
        sed -i "s/default.replication.factor=1/default.replication.factor=$KAFKA_DEFAULT_REPLICATION_FACTOR/g" ${KAFKA_HOME}/config/server.properties.tmp
    fi

    if [ ! -z "$KAFKA_MESSAGE_MAX_BYTES" ]; then
        sed -i "s/message.max.bytes=1000012/message.max.bytes=$KAFKA_MESSAGE_MAX_BYTES/g" ${KAFKA_HOME}/config/server.properties.tmp
    fi

    # Move the processed file back
    mv ${KAFKA_HOME}/config/server.properties.tmp ${KAFKA_HOME}/config/server.properties

    echo "Kafka configuration completed."
}

# Function to generate cluster ID if not exists
generate_cluster_id() {
    if [ ! -f "${KAFKA_DATA_DIR}/meta.properties" ]; then
        echo "Generating new Kafka cluster ID..."
        # Use JMX exporter for storage tool as well
        KAFKA_OPTS="-javaagent:${KAFKA_HOME}/jmx_prometheus_javaagent.jar=9999:${KAFKA_HOME}/jmx-config.yml" kafka-storage.sh format -t $(kafka-storage.sh random-uuid) -c ${KAFKA_HOME}/config/server.properties
        echo "Cluster ID generated successfully."
    else
        echo "Using existing cluster ID."
    fi
}

# Function to wait for Kafka to be ready
wait_for_kafka() {
    echo "Waiting for Kafka to be ready..."
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if kafka-topics.sh --bootstrap-server localhost:9092 --list > /dev/null 2>&1; then
            echo "Kafka is ready!"
            return 0
        fi

        echo "Attempt $attempt/$max_attempts: Kafka not ready yet, waiting..."
        sleep 2
        attempt=$((attempt + 1))
    done

    echo "Kafka failed to start within expected time."
    return 1
}

# Main execution
main() {
    echo "Starting Kafka container..."

    # Configure Kafka based on environment variables
    configure_kafka

    # Generate cluster ID if needed
    generate_cluster_id

    # Set JMX exporter as Java agent
    export KAFKA_OPTS="-javaagent:${KAFKA_HOME}/jmx_prometheus_javaagent.jar=9999:${KAFKA_HOME}/jmx-config.yml"

    # Execute the main command
    exec "$@"
}

# Run main function with all arguments
main "$@"
