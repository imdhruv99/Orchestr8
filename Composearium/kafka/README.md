# Kafka

This setup provides a Kafka cluster in KRaft mode with three brokers and Kafka UI for monitoring. It is hardware-agnostic and optimized for development with extensive environment variable control.

## Features

-   Kafka 3.9.0 in KRaft mode (no Zookeeper).
-   Three Kafka brokers with persistent data storage.
-   Kafka UI for cluster monitoring.
-   Custom bridge network for inter-container communication.
-   Resource limits for memory and CPU.
-   Extensive environment variable configurability.

## Configuration

-   `.env`: Shared configurations (e.g., image, cluster ID, network, broker settings, resource limits).
-   `docker-compose.yml`: Defines services with per-broker overrides (e.g., node ID, advertised listeners).

## Starting the Cluster

To start the Kafka cluster and Kafka UI:

```
docker-compose up -d
```

## Stopping the Cluster

To stop the cluster:

```
docker-compose down
```

To remove volumes and data:

```
docker-compose down -v
```

## Accessing Kafka UI

Kafka UI is available at `http://localhost:18080`. It is preconfigured to connect to the Kafka cluster.

## Using Kafka CLI

To run Kafka commands (e.g., create a topic), use `docker exec`:

```
docker exec -it kafka-broker-1 /opt/bitnami/kafka/bin/kafka-topics.sh --create --topic test --partitions 3 --replication-factor 3 --bootstrap-server localhost:9092
```

## Scaling the Cluster

To add more brokers:

1. Duplicate an existing broker service in `docker-compose.yml`.
2. Update the following for the new broker:
    - `container_name` and `hostname` (e.g., kafka-broker-4)
    - `KAFKA_CFG_NODE_ID` (e.g., 4)
    - `ports` (e.g., 19094:9091)
    - `KAFKA_CFG_ADVERTISED_LISTENERS` (e.g., `INTERNAL://kafka-broker-4:9092,EXTERNAL://localhost:19094`)
3. Update `KAFKA_CFG_CONTROLLER_QUORUM_VOTERS` in .env to include the new broker (e.g., append ,`4@kafka-broker-4:9093`).
4. Start the new broker with `docker-compose up -d`.

## Architecture Notes

-   **Multi-Architecture Support:** Uses Bitnami's Kafka image, supporting `x86_64`, `arm64`, and `Apple Silicon`.
-   Port Mappings:
    -   Broker 1: `localhost:19091`
    -   Broker 2: `localhost:19092`
    -   Broker 3: `localhost:19093`
    -   Kafka UI: `localhost:18080`
-   **Persistent Data:** Stored in `./data/kafka1`, `./data/kafka2`, etc.
-   **Cluster ID:** Set in `.env` and shared across brokers for consistency.
-   **Environment Control:** Most Kafka settings are configurable via `.env` for centralized management.
