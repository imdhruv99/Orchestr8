# Zookeeper

This setup provides a Zookeeper ensemble with three nodes using the Bitnami image. It is hardware-agnostic and optimized for development, with environment variable control for key settings.

## Features

-   Three Zookeeper nodes for high availability and quorum.
-   Persistent data storage for each node.
-   Custom bridge network for inter-container communication.
-   Resource limits for memory and CPU.
-   Environment variable configurability for tuning Zookeeper.

## Configuration

-   All configuration is managed via environment variables in `docker-compose.yml` (e.g., image, server ID, cluster settings, resource limits).
-   Data for each node is stored in `./data/zookeeper1`, `./data/zookeeper2`, and `./data/zookeeper3`.

## Starting the Ensemble

To start the Zookeeper ensemble:

```
docker-compose up -d
```

## Stopping the Ensemble

To stop the ensemble:

```
docker-compose down
```

To remove volumes and data:

```
docker-compose down -v
```

## Ports

-   Node 1: `localhost:2181`
-   Node 2: `localhost:2182`
-   Node 3: `localhost:2183`

## Environment Variables

Key environment variables (set in `docker-compose.yml`):

-   `ZOO_IMAGE`: Zookeeper Docker image (e.g., `bitnami/zookeeper:latest`).
-   `ZOO_SERVER_ID`: Unique server ID for each node.
-   `ZOO_SERVERS`: List of all servers in the ensemble (e.g., `zookeeper1:2888:3888;zookeeper2:2888:3888;zookeeper3:2888:3888`).
-   `ZOO_TICK_TIME`, `ZOO_INIT_LIMIT`, `ZOO_SYNC_LIMIT`: Zookeeper timing and synchronization settings.
-   `ZOO_MAX_CLIENT_CNXNS`: Max client connections per node.
-   `ZOO_4LW_COMMANDS_WHITELIST`: Whitelisted 4-letter commands.
-   `ZOO_MEM_LIMIT`, `ZOO_CPU_LIMIT`: Resource limits for each container.

## Architecture Notes

-   **Multi-Architecture Support:** Uses Bitnami's Zookeeper image, supporting `x86_64`, `arm64`, and Apple Silicon.
-   **Persistent Data:** Each node stores data in its own directory for durability.
-   **Cluster Formation:** The ensemble is defined by the `ZOO_SERVERS` variable, and each node is assigned a unique `ZOO_SERVER_ID`.
-   **Network:** All nodes communicate over a custom bridge network (`zookeeper-network`).
-   **Scaling:** To add more nodes, duplicate a service in `docker-compose.yml`, assign a new `ZOO_SERVER_ID`, update ports, and extend `ZOO_SERVERS` accordingly.
