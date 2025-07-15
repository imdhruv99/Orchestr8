# Flink

This setup provides an Apache Flink cluster with one JobManager and two TaskManagers, configured for high availability using Zookeeper. It is hardware-agnostic and optimized for development, with environment variable control for key settings.

## Features

-   Apache Flink cluster with 1 JobManager and 2 TaskManagers.
-   High-availability mode using Zookeeper ensemble.
-   Persistent data storage for each node.
-   Custom bridge network for inter-container communication.
-   Resource limits for memory and CPU.
-   Environment variable configurability for tuning Flink.

## Configuration

-   All configuration is managed via environment variables in `docker-compose.yml` (e.g., image, mode, resource limits).
-   Flink-specific settings are in `conf/flink-conf.yaml`.
-   Data for each node is stored in `./data/jobmanager`, `./data/taskmanager1`, and `./data/taskmanager2`.

## Starting the Cluster

To start the Flink cluster:

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

## Ports

-   JobManager UI: `localhost:8081`

## Environment Variables

Key environment variables (set in `docker-compose.yml`):

-   `FLINK_IMAGE`: Flink Docker image (e.g., `bitnami/flink:latest`).
-   `FLINK_JOBMANAGER_MODE`: Mode for JobManager (e.g., `jobmanager`).
-   `FLINK_TASKMANAGER_MODE`: Mode for TaskManagers (e.g., `taskmanager`).
-   `FLINK_JOBMANAGER_MEM_LIMIT`, `FLINK_JOBMANAGER_CPU_LIMIT`: Resource limits for JobManager.
-   `FLINK_TASKMANAGER_MEM_LIMIT`, `FLINK_TASKMANAGER_CPU_LIMIT`: Resource limits for TaskManagers.

## Architecture Notes

-   **Multi-Architecture Support:** Uses Bitnami's Flink image, supporting `x86_64`, `arm64`, and Apple Silicon.
-   **Persistent Data:** Each node stores data in its own directory for durability.
-   **High Availability:** Configured to use a Zookeeper ensemble for HA (see `conf/flink-conf.yaml`).
-   **Network:** All nodes communicate over a custom bridge network (`flink-network`) and connect to the Zookeeper network.
-   **Scaling:** To add more TaskManagers, duplicate a service in `docker-compose.yml`, assign a new name, and update volumes as needed.
