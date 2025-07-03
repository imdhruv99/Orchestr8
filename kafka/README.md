# Apache Kafka (KRaft mode) Docker Image

This image provides a production-ready, secure, and minimal Apache Kafka setup (KRaft mode, no Zookeeper) based on the hardened `golden-ubuntu` base image.

## Features

-   **KRaft mode** (no Zookeeper)
-   **Dynamic configuration** via environment variables
-   **Non-root execution** (runs as `kafka` user)
-   **Persistent data** in `/var/lib/kafka/data`
-   **JMX Exporter** for Prometheus metrics
-   **Security best practices** (minimal packages, hardened permissions)

## Quick Start

```sh
docker run -d \
  -e KAFKA_BROKER_ID=1 \
  -e KAFKA_NODE_ID=1 \
  -e KAFKA_LISTENERS="INTERNAL://0.0.0.0:19091,EXTERNAL://0.0.0.0:19092" \
  -e KAFKA_ADVERTISED_LISTENERS="INTERNAL://localhost:19091,EXTERNAL://localhost:19092" \
  -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP="INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT" \
  -e KAFKA_INTER_BROKER_LISTENER_NAME=INTERNAL \
  -e KAFKA_CONTROLLER_QUORUM_VOTERS="1@localhost:19093" \
  -e KAFKA_PROCESS_ROLES="broker,controller" \
  -e KAFKA_CLUSTER_ID="<your-cluster-id>" \
  -v kafka-data:/var/lib/kafka/data \
  -p 19091-19098:19091-19098 \
  dockyard/kafka:latest
```

## Environment Variables

| Variable                             | Description           | Default                                               |
| ------------------------------------ | --------------------- | ----------------------------------------------------- |
| KAFKA_BROKER_ID                      | Broker ID             | 1                                                     |
| KAFKA_NODE_ID                        | Node ID (KRaft)       | $KAFKA_BROKER_ID                                      |
| KAFKA_LISTENERS                      | Listener addresses    | INTERNAL://0.0.0.0:19091,EXTERNAL://0.0.0.0:19092     |
| KAFKA_ADVERTISED_LISTENERS           | Advertised listeners  | INTERNAL://localhost:19091,EXTERNAL://localhost:19092 |
| KAFKA_LISTENER_SECURITY_PROTOCOL_MAP | Listener protocol map | INTERNAL:PLAINTEXT,EXTERNAL:PLAINTEXT                 |
| KAFKA_INTER_BROKER_LISTENER_NAME     | Inter-broker listener | INTERNAL                                              |
| KAFKA_LOG_DIRS                       | Data directory        | /var/lib/kafka/data                                   |
| KAFKA_CONTROLLER_QUORUM_VOTERS       | KRaft quorum voters   |                                                       |
| KAFKA_PROCESS_ROLES                  | KRaft process roles   | broker,controller                                     |
| KAFKA_CLUSTER_ID                     | KRaft cluster ID      |                                                       |

## JMX Exporter

-   JMX Exporter Java agent is available at `/opt/jmx-exporter/jmx_prometheus_javaagent.jar`.
-   To enable, add to `KAFKA_OPTS`:
    ```sh
    -javaagent:/opt/jmx-exporter/jmx_prometheus_javaagent.jar=9999:/opt/jmx-exporter/config.yml
    ```

## Volumes

-   `/var/lib/kafka/data` — Kafka data (persistent)

## Security

-   Runs as non-root `kafka` user
-   Minimal packages, hardened permissions
-   Use Docker secrets or environment variables for sensitive config

## Example Compose

See project root for a sample `docker-compose.yml` for multi-broker KRaft cluster setup.
