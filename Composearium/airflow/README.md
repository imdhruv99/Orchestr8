# Airflow

This setup provides an Apache Airflow cluster with Web Server, Scheduler, and Triggerer components. It is hardware-agnostic and optimized for development with extensive environment variable control and integration with external PostgreSQL and Redis services.

## Prerequisites

This Airflow cluster requires PostgreSQL and Redis services to be running as prerequisites. Please ensure both services are started before launching Airflow. For setup and instructions, refer to:

-   [PostgreSQL README](../postgres/README.md)
-   [Redis README](../redis/README.md)

## Features

-   Apache Airflow cluster with Web Server, Scheduler, and Triggerer components.
-   LocalExecutor configuration for simplified development setup.
-   Integration with external PostgreSQL database for metadata storage.
-   Integration with external Redis for task queue management.
-   Persistent data storage for DAGs, logs, and plugins.
-   Custom bridge network for inter-container communication.
-   Resource limits for memory and CPU.
-   Environment variable configurability for tuning Airflow.
-   Health checks to ensure proper startup and connectivity.

## Configuration

-   `.env`: Shared configurations (e.g., image, database settings, resource limits, Airflow settings).
-   `docker-compose.yml`: Defines Airflow services with environment variable overrides.
-   `dags/`: Directory for Airflow DAG files (mounted as volume).
-   `logs/`: Directory for Airflow logs (mounted as volume).
-   `plugins/`: Directory for Airflow plugins (mounted as volume).

## Starting the Cluster

To start the Airflow cluster:

```
docker-compose up -d
```

**Note:** The first startup includes an initialization step that creates the database schema and admin user. This may take a few minutes.

## Stopping the Cluster

To stop the cluster:

```
docker-compose down
```

To remove volumes and data:

```
docker-compose down -v
```

## Accessing Airflow

-   **Airflow Web UI:** `http://localhost:8080`
-   **Default Admin Credentials:**
    -   Username: `imdhruv99`
    -   Password: `dhruv@123`

## Using Airflow CLI

To run Airflow commands, use `docker exec`:

```bash
# List DAGs
docker exec -it airflow-webserver airflow dags list

# Trigger a DAG
docker exec -it airflow-webserver airflow dags trigger <dag_id>

# Check task status
docker exec -it airflow-webserver airflow tasks list <dag_id> <task_id>
```

## Adding DAGs

Place your DAG files in the `dags/` directory. They will be automatically loaded by Airflow:

```bash
# Copy your DAG file to the dags directory
cp your_dag.py ./dags/

# The DAG will be automatically picked up by the scheduler
```

## Scaling the Cluster

To add more Airflow workers (for CeleryExecutor):

1. Duplicate the airflow-worker service in `docker-compose.yml`.
2. Update the following for the new worker:
    - `container_name` and `hostname` (e.g., airflow-worker-2)
    - `volumes` path if needed
3. Start the new worker with `docker-compose up -d airflow-worker-2`.

## Architecture Notes

-   **Multi-Architecture Support:** Uses official Apache Airflow image, supporting `x86_64`, `arm64`, and Apple Silicon.
-   Port Mappings:
    -   Airflow Web UI: `localhost:8080` (configurable via `AIRFLOW_UI_PORT`)
-   **Persistent Data:** Stored in `./dags`, `./logs`, and `./plugins` directories.
-   **External Dependencies:** Connects to external PostgreSQL and Redis services for metadata and task queue management.
-   **Health Checks:** Web server includes health checks to ensure proper startup.
-   **Environment Control:** Most Airflow settings are configurable via `.env` for centralized management.
-   **Network Isolation:** All services communicate over custom bridge networks and connect to external service networks.

## Environment Variables

Key environment variables (set in `.env`):

### Airflow Settings

-   `AIRFLOW_IMAGE`: Airflow Docker image (e.g., `apache/airflow:2.8.1`).
-   `AIRFLOW_UI_PORT`: Port for Airflow web interface (e.g., `8080`).
-   `AIRFLOW__CORE__EXECUTOR`: Executor type (e.g., `LocalExecutor`, `CeleryExecutor`).
-   `AIRFLOW__WEBSERVER__RBAC`: Enable role-based access control (e.g., `True`).
-   `AIRFLOW__WEBSERVER__SECRET_KEY`: Secret key for web server security.
-   `AIRFLOW__CORE__FERNET_KEY`: Fernet key for encrypted connections.

### Database Settings

-   `AIRFLOW__DATABASE__SQL_ALCHEMY_CONN`: PostgreSQL connection string (e.g., `postgresql+psycopg2://user:password@postgres:5432/airflow`).

### Redis Settings (for CeleryExecutor)

-   `AIRFLOW__CELERY__BROKER_URL`: Redis broker URL (e.g., `redis://redis:6379/0`).
-   `AIRFLOW__CELERY__RESULT_BACKEND`: Redis result backend URL (e.g., `redis://redis:6379/0`).

### Resource Limits

-   `AIRFLOW_MEM_LIMIT`: Memory limit for Airflow containers (e.g., `1g`).
-   `AIRFLOW_CPU_LIMIT`: CPU limit for Airflow containers (e.g., `0.5`).

## Airflow Configuration Details

The setup provides:

-   **LocalExecutor:** Simplified configuration for development without additional message queue requirements.
-   **External Database:** Uses PostgreSQL for metadata storage, enabling better performance and scalability.
-   **External Redis:** Available for CeleryExecutor configuration if needed.
-   **Volume Mounts:** DAGs, logs, and plugins are mounted as volumes for persistence and easy development.
-   **Health Monitoring:** Web server includes health checks for proper startup verification.
-   **Security:** RBAC enabled with configurable secret keys and Fernet encryption.

## Troubleshooting

### Common Issues

1. **Database Connection Errors:**

    - Ensure PostgreSQL is running and accessible
    - Check the `AIRFLOW__DATABASE__SQL_ALCHEMY_CONN` environment variable

2. **DAGs Not Loading:**

    - Verify DAG files are in the `dags/` directory
    - Check file permissions and syntax
    - Review scheduler logs: `docker logs airflow-scheduler`

3. **Web UI Not Accessible:**
    - Check if the web server is healthy: `docker logs airflow-webserver`
    - Verify the port mapping in `docker-compose.yml`

### Logs

View logs for specific components:

```bash
# Web server logs
docker logs airflow-webserver

# Scheduler logs
docker logs airflow-scheduler

# Triggerer logs
docker logs airflow-triggerer
```
