# Spark

This setup provides an Apache Spark cluster with one Master and two Worker nodes, configured for high availability using Zookeeper. It is hardware-agnostic and optimized for development, with environment variable control for key settings.

## Prerequisites

This Spark cluster requires a Zookeeper ensemble to be running as a prerequisite. Please ensure the Zookeeper cluster is started before launching Spark. For setup and instructions, refer to the [Zookeeper README](../zookeeper/README.md).

## Features

-   Apache Spark cluster with 1 Master and 2 Workers.
-   High-availability mode using Zookeeper for master recovery.
-   Persistent data and log storage for each node.
-   Custom bridge network for inter-container communication.
-   Resource limits for memory and CPU.
-   Environment variable configurability for tuning Spark.

## Configuration

-   All configuration is managed via environment variables in `docker-compose.yml` (e.g., image, Zookeeper settings, resource limits).
-   Data and logs for each node are stored in `./data/<node>` and `./logs/<node>` respectively.

## Starting the Cluster

To start the Spark cluster:

```bash
docker-compose up -d
```

## Stopping the Cluster

To stop the cluster:

```bash
docker-compose down
```

To remove volumes and data:

```bash
docker-compose down -v
```

## Accessing Spark UI

-   **Spark Master Web UI:** `http://localhost:${SPARK_MASTER_WEB_PORT}`
-   **Spark Worker 1 Web UI:** `http://localhost:${SPARK_WORKER_WEB_PORT1}`
-   **Spark Worker 2 Web UI:** `http://localhost:${SPARK_WORKER_WEB_PORT2}`

## Using Spark CLI

To run Spark commands (e.g., submit a job), use `docker exec`:

```bash
docker exec -it spark-master spark-submit --master spark://spark-master:7077 <your_spark_job.py>
```

## Scaling the Cluster

To add more Spark workers:

1. Duplicate an existing worker service in `docker-compose.yml`.
2. Update the following for the new worker:
    - `container_name` and `hostname` (e.g., spark-worker-3)
    - `ports` (e.g., assign a new web UI port)
    - `volumes` path (e.g., `./data/spark-worker-3`, `./logs/spark-worker-3`)
3. Start the new worker with `docker-compose up -d spark-worker-3`.

## Architecture Notes

-   **Multi-Architecture Support:** Uses official Spark image, supporting `x86_64`, `arm64`, and Apple Silicon.
-   **Persistent Data:** Each node stores data and logs in its own directory for durability.
-   **High Availability:** Configured to use a Zookeeper ensemble for master recovery (see environment variables below).
-   **Network:** All nodes communicate over a custom bridge network (`spark-network`) and connect to the Zookeeper network.
-   **Resource Limits:** Memory and CPU limits are configurable per container.

## Environment Variables

Key environment variables (set in `docker-compose.yml` or externally):

-   `SPARK_IMAGE`: Spark Docker image (e.g., `bitnami/spark:latest`).
-   `SPARK_LOG_LEVEL`: Log level for Spark processes (e.g., `INFO`).
-   `SPARK_ZOOKEEPER_URL`: Zookeeper connection string (e.g., `zookeeper1:2181,zookeeper2:2181,zookeeper3:2181`).
-   `SPARK_ZOOKEEPER_DIR`: Zookeeper directory for Spark recovery (e.g., `/spark-ha`).
-   `SPARK_MASTER_PORT`: Port for Spark master service (default: `7077`).
-   `SPARK_MASTER_WEB_PORT`: Port for Spark master web UI (default: `8080`).
-   `SPARK_WORKER_WEB_PORT1`: Port for Spark worker 1 web UI (default: `8081`).
-   `SPARK_WORKER_WEB_PORT2`: Port for Spark worker 2 web UI (default: `8082`).
-   `SPARK_WORK_DIR`: Directory for Spark working data (e.g., `/opt/spark/work`).
-   `SPARK_LOG_DIR`: Directory for Spark logs (e.g., `/opt/spark/logs`).
-   `SPARK_MEM_LIMIT`: Memory limit for Spark containers (e.g., `2g`).
-   `SPARK_CPU_LIMIT`: CPU limit for Spark containers (e.g., `1.0`).
-   `SPARK_WORKER_CORES`: Number of cores for each worker (e.g., `2`).
-   `SPARK_WORKER_MEMORY`: Memory allocation for each worker (e.g., `1g`).

## Troubleshooting

-   **Master not available:** Ensure Zookeeper is running and accessible, and the `SPARK_ZOOKEEPER_URL` is correct.
-   **Web UI not accessible:** Check port mappings and container health.
-   **Worker not connecting:** Verify the master URL and network configuration.
