# Apache Zookeeper

A production-ready, secure, and minimal Apache Zookeeper setup based on the hardened `golden-ubuntu` base image. Designed for distributed coordination and service discovery in modern containerized environments.

## Features

-   **Production Ready**: Built on hardened Ubuntu base with security best practices
-   **Dynamic Configuration**: Configurable via environment variables
-   **Non-root Execution**: Runs as dedicated `zookeeper` user
-   **Persistent Data**: Stores data in `/var/lib/zookeeper/data`
-   **JMX Exporter**: Prometheus metrics monitoring
-   **Cluster Support**: Configurable for single-node and multi-node clusters
-   **Security Hardened**: Minimal attack surface with essential packages only

## Quick Start

### Build the Image

Multi-Platform build command and push to your docker-hub:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t <docker-hub username>/zookeeper:1.0.0 --push .
```

OR for local use:

```bash
docker build -t zookeeper:1.0.0 .
```

### Run as Single Container

```sh
docker run -d \
  --name single_node_zookeeper \
  -e ZOOKEEPER_MYID=1 \
  -e ZOOKEEPER_SERVERS="server.1=0.0.0.0:2888:3888;2181" \
  -v zookeeper-data:/var/lib/zookeeper/data \
  -v zookeeper-logs:/var/lib/zookeeper/logs \
  -p 2181:2181 \
  -p 2888:2888 \
  -p 3888:3888 \
  -p 9999:9999 \
  imdhruv99/zookeeper:1.0.0
```

### Run as Zookeeper Cluster

```sh
# Create a 3-node cluster
docker run -d \
  --name zookeeper-1 \
  --network zookeeper-net \
  -e ZOOKEEPER_MYID=1 \
  -e ZOOKEEPER_SERVERS="server.1=zookeeper-1:2888:3888;2181 server.2=zookeeper-2:2888:3888;2181 server.3=zookeeper-3:2888:3888;2181" \
  -v zookeeper-data-1:/var/lib/zookeeper/data \
  -v zookeeper-logs-1:/var/lib/zookeeper/logs \
  -p 2181:2181 \
  imdhruv99/zookeeper:1.0.0

docker run -d \
  --name zookeeper-2 \
  --network zookeeper-net \
  -e ZOOKEEPER_MYID=2 \
  -e ZOOKEEPER_SERVERS="server.1=zookeeper-1:2888:3888;2181 server.2=zookeeper-2:2888:3888;2181 server.3=zookeeper-3:2888:3888;2181" \
  -v zookeeper-data-2:/var/lib/zookeeper/data \
  -v zookeeper-logs-2:/var/lib/zookeeper/logs \
  -p 2182:2181 \
  imdhruv99/zookeeper:1.0.0

docker run -d \
  --name zookeeper-3 \
  --network zookeeper-net \
  -e ZOOKEEPER_MYID=3 \
  -e ZOOKEEPER_SERVERS="server.1=zookeeper-1:2888:3888;2181 server.2=zookeeper-2:2888:3888;2181 server.3=zookeeper-3:2888:3888;2181" \
  -v zookeeper-data-3:/var/lib/zookeeper/data \
  -v zookeeper-logs-3:/var/lib/zookeeper/logs \
  -p 2183:2181 \
  imdhruv99/zookeeper:1.0.0
```

## Environment Variables

| Variable                   | Description                   | Default                         |
| -------------------------- | ----------------------------- | ------------------------------- |
| ZOOKEEPER_MYID             | Zookeeper server ID           | 1                               |
| ZOOKEEPER_SERVERS          | Server configuration string   | server.1=0.0.0.0:2888:3888;2181 |
| ZOOKEEPER_DATA_DIR         | Data directory                | /var/lib/zookeeper/data         |
| ZOOKEEPER_LOG_DIR          | Log directory                 | /var/lib/zookeeper/logs         |
| ZOOKEEPER_CLIENT_PORT      | Client connection port        | 2181                            |
| ZOOKEEPER_TICK_TIME        | Tick time in milliseconds     | 2000                            |
| ZOOKEEPER_INIT_LIMIT       | Initial synchronization limit | 10                              |
| ZOOKEEPER_SYNC_LIMIT       | Sync limit                    | 5                               |
| ZOOKEEPER_MAX_CLIENT_CNXNS | Max client connections        | 60                              |

## JMX Exporter

-   JMX Exporter Java agent is available at `/opt/zookeeper/jmx_prometheus_javaagent.jar`
-   Configuration file at `/opt/zookeeper/jmx-config.yml`
-   Metrics exposed on port 9999
-   Automatically configured via `ZOOKEEPER_OPTS` environment variable

## Ports

-   **2181**: Client connections (configurable via `ZOOKEEPER_CLIENT_PORT`)
-   **2888**: Peer communication (leader election)
-   **3888**: Leader election
-   **9999**: JMX metrics (Prometheus)

## Volumes

-   `/var/lib/zookeeper/data` — Zookeeper data (persistent)
-   `/var/lib/zookeeper/logs` — Zookeeper logs (persistent)

## Security

-   Runs as non-root `zookeeper` user
-   Minimal packages, hardened permissions
-   Use Docker secrets or environment variables for sensitive config
-   Based on hardened Ubuntu base image

## Monitoring

### Health Check

The container includes a health check that verifies Zookeeper is responding:

```bash
echo ruok | nc localhost 2181
```

Expected response: `imok`

### Four Letter Word Commands

Zookeeper supports various 4-letter word commands for monitoring:

```bash
# Check if server is running
echo ruok | nc localhost 2181

# Get server statistics
echo stat | nc localhost 2181

# Get server configuration
echo conf | nc localhost 2181

# Get environment variables
echo envi | nc localhost 2181

# Get server connections
echo cons | nc localhost 2181
```

## Configuration

### Static Configuration

The image includes a default `zoo.cfg` file with production-ready settings:

-   Automatic snapshot purging
-   Optimized performance settings
-   JMX monitoring enabled
-   Four letter word commands enabled

### Dynamic Configuration

The entrypoint script can generate configuration dynamically based on environment variables, allowing for flexible deployment scenarios.

## Example Docker Compose

```yaml
version: "3.8"

services:
    zookeeper:
        image: imdhruv99/zookeeper:1.0.0
        container_name: zookeeper
        environment:
            - ZOOKEEPER_MYID=1
            - ZOOKEEPER_SERVERS=server.1=0.0.0.0:2888:3888;2181
        volumes:
            - zookeeper-data:/var/lib/zookeeper/data
            - zookeeper-logs:/var/lib/zookeeper/logs
        ports:
            - "2181:2181"
            - "2888:2888"
            - "3888:3888"
            - "9999:9999"
        healthcheck:
            test: ["CMD", "echo", "ruok", "|", "nc", "localhost", "2181"]
            interval: 30s
            timeout: 10s
            retries: 3
            start_period: 60s

volumes:
    zookeeper-data:
    zookeeper-logs:
```

## File Structure

```
zookeeper/
├── Dockerfile              # Main container definition
├── docker-entrypoint.sh    # Container entrypoint script
├── configs/
│   ├── zoo.cfg            # Zookeeper configuration
│   └── jmx-config.yml     # JMX monitoring configuration
├── README.md               # Documentation
└── .dockerignore           # Excludes unnecessary files from Docker build context
```
