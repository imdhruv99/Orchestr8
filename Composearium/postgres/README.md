# PostgreSQL

This setup provides a PostgreSQL database server with pgAdmin for database management. It is hardware-agnostic and optimized for development with extensive environment variable control and custom configuration files.

## Features

-   PostgreSQL 15+ database server with persistent data storage.
-   pgAdmin web interface for database management and monitoring.
-   Custom bridge network for inter-container communication.
-   Resource limits for memory and CPU.
-   Extensive environment variable configurability.
-   Custom PostgreSQL configuration files for optimized performance.
-   Health checks to ensure proper startup and connectivity.

## Configuration

-   `.env`: Shared configurations (e.g., image, database settings, resource limits, pgAdmin settings).
-   `docker-compose.yml`: Defines PostgreSQL and pgAdmin services with environment variable overrides.
-   `conf/postgresql.conf`: Custom PostgreSQL configuration for performance tuning.
-   `conf/pg_hba.conf`: PostgreSQL host-based authentication configuration.

## Starting the Database

To start PostgreSQL and pgAdmin:

```
docker-compose up -d
```

## Stopping the Database

To stop the services:

```
docker-compose down
```

To remove volumes and data:

```
docker-compose down -v
```

## Accessing PostgreSQL

-   **PostgreSQL Server:** `localhost:5432`
-   **pgAdmin Web Interface:** `http://localhost:5050`

## Connecting to PostgreSQL

### Using psql (if available locally)

```bash
psql -h localhost -p 5432 -U ${POSTGRES_USER} -d ${POSTGRES_DB}
```

### Using Docker exec

```bash
docker exec -it postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
```

## Using pgAdmin

1. Open your browser and navigate to `http://localhost:5050`
2. Login with the credentials defined in your `.env` file:
    - Email: `${PGADMIN_DEFAULT_EMAIL}`
    - Password: `${PGADMIN_DEFAULT_PASSWORD}`
3. Add a new server connection:
    - Host: `postgres` (container name)
    - Port: `5432`
    - Username: `${POSTGRES_USER}`
    - Password: `${POSTGRES_PASSWORD}`

## Scaling the Setup

To add more PostgreSQL instances (for replication or clustering):

1. Duplicate the postgres service in `docker-compose.yml`.
2. Update the following for the new instance:
    - `container_name` and `hostname` (e.g., postgres-replica)
    - `ports` (e.g., 5433:5432)
    - `volumes` path (e.g., `./data/postgres-replica:/var/lib/postgresql/data`)
3. Configure replication settings in `postgresql.conf` if needed.
4. Start the new instance with `docker-compose up -d postgres-replica`.

## Architecture Notes

-   **Multi-Architecture Support:** Uses official PostgreSQL image, supporting `x86_64`, `arm64`, and Apple Silicon.
-   Port Mappings:
    -   PostgreSQL: `localhost:5432`
    -   pgAdmin: `localhost:5050`
-   **Persistent Data:** Stored in `./data/postgres` for PostgreSQL and `./data/pgadmin` for pgAdmin.
-   **Custom Configuration:** PostgreSQL uses custom `postgresql.conf` and `pg_hba.conf` files for optimized settings.
-   **Health Checks:** PostgreSQL includes health checks using `pg_isready` to ensure proper startup.
-   **Environment Control:** Most PostgreSQL and pgAdmin settings are configurable via `.env` for centralized management.
-   **Network Isolation:** All services communicate over a custom bridge network (`postgres-network`).

## Environment Variables

Key environment variables (set in `.env`):

### PostgreSQL Settings

-   `POSTGRES_IMAGE`: PostgreSQL Docker image (e.g., `postgres:15`).
-   `POSTGRES_DB`: Default database name.
-   `POSTGRES_USER`: Default database user.
-   `POSTGRES_PASSWORD`: Default database password.
-   `POSTGRES_INITDB_ARGS`: Additional arguments for database initialization.
-   `POSTGRES_HOST_AUTH_METHOD`: Authentication method (e.g., `trust`, `md5`).

### Performance Tuning

-   `POSTGRES_MAX_CONNECTIONS`: Maximum number of concurrent connections.
-   `POSTGRES_SHARED_BUFFERS`: Size of shared memory buffers.
-   `POSTGRES_EFFECTIVE_CACHE_SIZE`: Effective cache size for query planning.
-   `POSTGRES_WORK_MEM`: Memory for query operations.
-   `POSTGRES_MAINTENANCE_WORK_MEM`: Memory for maintenance operations.
-   `POSTGRES_WAL_BUFFERS`: Write-ahead log buffers.
-   `POSTGRES_MIN_WAL_SIZE`, `POSTGRES_MAX_WAL_SIZE`: WAL file size limits.

### pgAdmin Settings

-   `PGADMIN_IMAGE`: pgAdmin Docker image (e.g., `dpage/pgadmin4`).
-   `PGADMIN_HOST_PORT`: Port for pgAdmin web interface (e.g., `5050`).
-   `PGADMIN_DEFAULT_EMAIL`: Default pgAdmin login email.
-   `PGADMIN_DEFAULT_PASSWORD`: Default pgAdmin login password.

### Resource Limits

-   `POSTGRES_MEM_LIMIT`: Memory limit for PostgreSQL container.
-   `POSTGRES_CPU_LIMIT`: CPU limit for PostgreSQL container.
