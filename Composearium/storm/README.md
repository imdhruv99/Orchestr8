# Storm

This setup provides an Apache Storm cluster with one Nimbus, three Supervisors, and a Storm UI for monitoring. It is hardware-agnostic and optimized for development with extensive environment variable control.

## Prerequisites

This Storm cluster requires a Zookeeper ensemble to be running as a prerequisite. Please ensure the Zookeeper cluster is started before launching Storm. For setup and instructions, refer to the [Zookeeper README](../zookeeper/README.md).

## Features

-   Apache Storm cluster with 1 Nimbus, 3 Supervisors, and 1 UI.
-   High-availability mode using Zookeeper ensemble.
-   Persistent data storage for each node.
-   Custom bridge network for inter-container communication.
-   Resource limits for memory and CPU.
-   Environment variable configurability for tuning Storm.

## Configuration

-   `.env`: Shared configurations (e.g., image, Zookeeper settings, resource limits).
-   `docker-compose.yml`: Defines services with per-node overrides (e.g., container names, dependencies).
-   `storm.yaml`: Storm-specific configuration file mounted to all containers.

## Starting the Cluster

To start the Storm cluster:

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

## Accessing Storm UI

Storm UI is available at `http://localhost:48080`. It provides a web interface for monitoring and managing Storm topologies.

## Using Storm CLI

To run Storm commands (e.g., submit a topology), use `docker exec`:

```
docker exec -it nimbus storm jar /path/to/your-topology.jar com.example.TopologyMain topology-name
```

## Scaling the Cluster

To add more supervisors:

1. Duplicate an existing supervisor service in `docker-compose.yml`.
2. Update the following for the new supervisor:
    - `container_name` and service name (e.g., supervisor4)
    - `volumes` path (e.g., `./data/supervisor4:/apache-storm/data`)
3. Start the new supervisor with `docker-compose up -d supervisor4`.

## Architecture Notes

-   **Multi-Architecture Support:** Uses Apache Storm image, supporting `x86_64`, `arm64`, and Apple Silicon.
-   Port Mappings:
    -   Nimbus: `localhost:6667` (Thrift port)
    -   Storm UI: `localhost:48080`
-   **Persistent Data:** Stored in `./data/nimbus`, `./data/supervisor1`, etc.
-   **Zookeeper Integration:** Connects to external Zookeeper ensemble for coordination.
-   **Environment Control:** Most Storm settings are configurable via `.env` for centralized management.
-   **Health Checks:** Nimbus includes health checks to ensure proper startup order.
-   **Supervisor Slots:** Each supervisor is configured with 4 worker slots (ports 6700-6703).

## Environment Variables

Key environment variables (set in `.env`):

-   `STORM_IMAGE`: Storm Docker image (e.g., `apache/storm:latest`).
-   `ZOOKEEPER_SERVERS`: List of Zookeeper servers (e.g., `zookeeper1,zookeeper2,zookeeper3`).
-   `ZOOKEEPER_PORT`: Zookeeper port (e.g., `2181`).
-   `STORM_NIMBUS_MEM`, `STORM_NIMBUS_CPU`: Resource limits for Nimbus.
-   `STORM_SUPERVISOR_MEM`, `STORM_SUPERVISOR_CPU`: Resource limits for Supervisors.
-   `STORM_UI_MEM`, `STORM_UI_CPU`: Resource limits for Storm UI.
