# Apache Kafka

A production-ready Apache Kafka 3.9.0 image built on the hardened `golden-ubuntu` base. Features KRaft mode (no Zookeeper), configurable multi-broker support, JMX monitoring capabilities, and optimized for containerized environments.

## Features

-   **KRaft Mode**: No Zookeeper dependency, using Kafka's built-in consensus mechanism
-   **Dynamic Configuration**: All server.properties settings configurable via environment variables
-   **Security Hardened**: Based on golden-ubuntu with non-root user execution
-   **JMX Monitoring**: Built-in JMX exporter for Prometheus metrics
-   **Health Checks**: Built-in health monitoring
-   **Multi-broker Support**: Easy cluster configuration
-   **Persistent Storage**: Stores persistent data at `/var/lib/kafka/data` and `/var/lib/kafka/logs`
-   **Minimal Footprint**: Optimized for size and security

## Security Features

-   Non-root execution under dedicated `kafka` user
-   Isolated Kafka user and group
-   Secure file permissions on data directories
-   Minimal attack surface with hardened base image
-   Custom Kafka configuration for enhanced security

## Environment Variables

### Basic Configuration

| Variable                         | Default             | Description                    |
| -------------------------------- | ------------------- | ------------------------------ |
| `KAFKA_NODE_ID`                  | `1`                 | Unique node ID for this broker |
| `KAFKA_PROCESS_ROLES`            | `broker,controller` | Roles this node performs       |
| `KAFKA_CONTROLLER_QUORUM_VOTERS` | `1@localhost:9093`  | Controller quorum voters       |

### Listener Configuration

| Variable                               | Default                                    | Description                   |
| -------------------------------------- | ------------------------------------------ | ----------------------------- |
| `KAFKA_LISTENERS`                      | `PLAINTEXT://:9092,CONTROLLER://:9093`     | Listener endpoints            |
| `KAFKA_ADVERTISED_LISTENERS`           | `PLAINTEXT://localhost:9092`               | Advertised listener addresses |
| `KAFKA_LISTENER_SECURITY_PROTOCOL_MAP` | `PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT` | Security protocols            |

### Performance Tuning

| Variable                            | Default   | Description                |
| ----------------------------------- | --------- | -------------------------- |
| `KAFKA_NUM_NETWORK_THREADS`         | `3`       | Number of network threads  |
| `KAFKA_NUM_IO_THREADS`              | `8`       | Number of I/O threads      |
| `KAFKA_SOCKET_SEND_BUFFER_BYTES`    | `102400`  | Socket send buffer size    |
| `KAFKA_SOCKET_RECEIVE_BUFFER_BYTES` | `102400`  | Socket receive buffer size |
| `KAFKA_MESSAGE_MAX_BYTES`           | `1000012` | Maximum message size       |

### Log Configuration

| Variable                    | Default               | Description                             |
| --------------------------- | --------------------- | --------------------------------------- |
| `KAFKA_LOG_DIRS`            | `/var/lib/kafka/logs` | Log directory                           |
| `KAFKA_NUM_PARTITIONS`      | `3`                   | Default number of partitions            |
| `KAFKA_LOG_RETENTION_HOURS` | `168`                 | Log retention in hours                  |
| `KAFKA_LOG_RETENTION_BYTES` | `-1`                  | Log retention in bytes (-1 = unlimited) |
| `KAFKA_LOG_SEGMENT_BYTES`   | `1073741824`          | Log segment size                        |

### Topic Configuration

| Variable                           | Default | Description                |
| ---------------------------------- | ------- | -------------------------- |
| `KAFKA_AUTO_CREATE_TOPICS_ENABLE`  | `true`  | Auto-create topics         |
| `KAFKA_DELETE_TOPIC_ENABLE`        | `true`  | Allow topic deletion       |
| `KAFKA_DEFAULT_REPLICATION_FACTOR` | `1`     | Default replication factor |
| `KAFKA_MIN_INSYNC_REPLICAS`        | `1`     | Minimum in-sync replicas   |

### JMX Configuration

| Variable                 | Default | Description        |
| ------------------------ | ------- | ------------------ |
| `KAFKA_JMX_PORT`         | `9999`  | JMX port           |
| `KAFKA_JMX_HOSTNAME`     | ``      | JMX hostname       |
| `KAFKA_JMX_AUTHENTICATE` | `false` | JMX authentication |
| `KAFKA_JMX_SSL`          | `false` | JMX SSL            |

## Build & Run

### Build the Image

Build command if you want to push to your docker-hub:

```bash
docker build -t <docker-hub username>/kafka:1.0.0 .
```

OR for local use:

```bash
docker build -t kafka:1.0.0 .
```

### Run the Container

Basic run command:

```bash
docker run -d --name kafka -p 9092:9092 -p 9093:9093 -p 9999:9999 <docker-hub username>/kafka:1.0.0
```

### Advanced Usage

With custom volume mount:

```bash
docker run -d \
  --name kafka \
  -p 9092:9092 \
  -p 9093:9093 \
  -p 9999:9999 \
  -v kafka-data:/var/lib/kafka/data \
  -v kafka-logs:/var/lib/kafka/logs \
  <docker-hub username>/kafka:1.0.0
```

With environment variables:

```bash
docker run -d \
  --name kafka \
  -p 9092:9092 \
  -p 9093:9093 \
  -p 9999:9999 \
  -e KAFKA_NODE_ID=1 \
  -e KAFKA_NUM_PARTITIONS=5 \
  -e KAFKA_LOG_RETENTION_HOURS=24 \
  -e KAFKA_MESSAGE_MAX_BYTES=2000000 \
  -v kafka-data:/var/lib/kafka/data \
  -v kafka-logs:/var/lib/kafka/logs \
  <docker-hub username>/kafka:1.0.0
```

## Docker Compose

The Kafka image includes several docker-compose configurations for different use cases:

### Simple Single Node

```bash
# Start a single Kafka broker
docker-compose -f compose/docker-compose.simple.yml up -d

# View logs
docker-compose -f compose/docker-compose.simple.yml logs -f kafka

# Stop
docker-compose -f compose/docker-compose.simple.yml down
```

### Full Configuration

```bash
# Start with all configuration options
docker-compose -f compose/docker-compose.yml up -d

# View logs
docker-compose -f compose/docker-compose.yml logs -f kafka

# Stop
docker-compose -f compose/docker-compose.yml down
```

### Multi-Broker Cluster

```bash
# Start a 3-broker cluster
docker-compose -f compose/docker-compose.cluster.yml up -d

# View logs for all brokers
docker-compose -f compose/docker-compose.cluster.yml logs -f

# Stop cluster
docker-compose -f compose/docker-compose.cluster.yml down
```

### Available Compose Files

-   **`compose/docker-compose.simple.yml`**: Basic single-node setup
-   **`compose/docker-compose.yml`**: Full configuration with optional services (commented out)
-   **`compose/docker-compose.cluster.yml`**: 3-broker cluster setup

## Configuration

### Kafka Configuration

The image uses a custom `server.properties` file located at `/opt/kafka/config/server.properties`. You can modify this file or override settings using environment variables.

### Data Persistence

Kafka data is stored in `/var/lib/kafka/data` and logs in `/var/lib/kafka/logs` which are exposed as Docker volumes. This ensures data persistence across container restarts.

## Connecting to Kafka

### From Host Machine

```bash
# List topics
kafka-topics.sh --bootstrap-server localhost:9092 --list

# Or connect using docker exec
docker exec -it kafka kafka-topics.sh --bootstrap-server localhost:9092 --list
```

### From Another Container

```bash
# If running in Docker Compose or Docker network
kafka-topics.sh --bootstrap-server kafka:9092 --list
```

## Monitoring

### JMX Metrics

JMX metrics are available on port 9999. You can access them directly:

```bash
curl http://localhost:9999/metrics
```

### Health Check

The container includes a health check that verifies Kafka is responding to topic listing requests.

## Ports

-   `9092`: Kafka broker port
-   `9093`: Kafka controller port
-   `9999`: JMX monitoring port

## Volumes

-   `/var/lib/kafka/data`: Kafka data directory (persistent)
-   `/var/lib/kafka/logs`: Kafka log directory (persistent)

## File Structure

```
kafka/
├── Dockerfile              # Main container definition
├── docker-entrypoint.sh    # Container entrypoint script
├── configs/
│   ├── server.properties   # Kafka configuration
│   └── jmx-config.yml      # JMX exporter configuration
├── compose/
│   ├── docker-compose.yml      # Full docker-compose configuration
│   ├── docker-compose.simple.yml # Simple single-node setup
│   └── docker-compose.cluster.yml # Multi-broker cluster setup
├── README.md               # Documentation
├── example.env             # Example environment variables
└── .dockerignore           # Excludes unnecessary files from Docker build context
```

## Version Information

-   **Kafka Version**: 3.9.0
-   **Scala Version**: 2.13
-   **Java Version**: OpenJDK 17
-   **JMX Exporter**: 0.20.0
-   **Base Image**: imdhruv99/golden-ubuntu:1.0.0
