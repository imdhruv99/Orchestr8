# PostgreSQL

A production-ready PostgreSQL 16 image built on the hardened `golden-ubuntu` base. Follows strict security practices with non-root users, isolated PostgreSQL ownership, custom configs, and a minimal dependency set.

## Features

-   **Security First**: Uses non-root base image (`golden-ubuntu`) with hardened security
-   **Dedicated User**: Runs PostgreSQL under dedicated `postgres` user (UID: 999)
-   **Custom Configuration**: Configurable with custom `postgresql.conf`
-   **Persistent Storage**: Stores persistent data at `/var/lib/postgresql/data`
-   **Secure Permissions**: 700 permissions on data directory, owned by postgres user
-   **Minimal Footprint**: Optimized for size and security
-   **Multi-stage Build**: Efficient build process (reverted to single-stage for size optimization)

## Security Features

-   Non-root execution
-   Isolated PostgreSQL user and group
-   Secure file permissions (700 on data directory)
-   Minimal attack surface with hardened base image
-   Custom PostgreSQL configuration for enhanced security

## Environment Variables

-   `POSTGRES_VERSION`: PostgreSQL version (default: 16)
-   `PGDATA`: PostgreSQL data directory (default: `/var/lib/postgresql/data`)
-   `PATH`: Includes PostgreSQL binaries

## Build & Run

### Build the Image

Multi-Platform build command and push to your docker-hub:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t <docker-hub username>/postgres:1.0.0 --push .
```

OR for local use:

```bash
docker build -t postgres:1.0.0 .
```

### Run the Container

Basic run command:

```bash
docker run -d --name postgres -p 5432:5432 <docker-hub username>/postgres:1.0.0
```

### Advanced Usage

With custom volume mount:

```bash
docker run -d \
  --name postgres \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  <docker-hub username>/postgres:1.0.0
```

With environment variables:

```bash
docker run -d \
  --name postgres \
  -p 5432:5432 \
  -e POSTGRES_VERSION=16 \
  -e PGDATA=/var/lib/postgresql/data \
  <docker-hub username>/postgres:1.0.0
```

## Configuration

### PostgreSQL Configuration

The image uses a custom `postgresql.conf` file located at `/etc/postgresql/postgresql.conf`. You can modify this file to adjust PostgreSQL settings according to your needs.

### Data Persistence

PostgreSQL data is stored in `/var/lib/postgresql/data` which is exposed as a Docker volume. This ensures data persistence across container restarts.

## Connecting to PostgreSQL

### From Host Machine

```bash
# Connect using psql (if installed locally)
psql -h localhost -p 5432 -U postgres

# Or connect using docker exec
docker exec -it postgres psql -U postgres
```

### From Another Container

```bash
# If running in Docker Compose or Docker network
psql -h postgres -p 5432 -U postgres
```

## File Structure

```
postgres/
├── Dockerfile              # Main container definition
├── docker-entrypoint.sh    # Container entrypoint script
├── postgresql.conf         # PostgreSQL configuration
├── README.md               # Documentation
└── .dockerignore           # Excludes unnecessary files from Docker build context
```
