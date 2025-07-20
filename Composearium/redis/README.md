# Redis

This setup provides a Redis server with Redis Commander for monitoring and management. It is hardware-agnostic and optimized for development with extensive environment variable control and custom configuration files.

## Features

-   Redis server with persistent data storage and AOF (Append-Only File) persistence.
-   Redis Commander web interface for database management and monitoring.
-   Custom bridge network for inter-container communication.
-   Resource limits for memory and CPU.
-   Extensive environment variable configurability.
-   Custom Redis configuration file for optimized performance.
-   Health checks to ensure proper startup and connectivity.

## Configuration

-   `.env`: Shared configurations (e.g., image, Redis settings, resource limits, Redis Commander settings).
-   `docker-compose.yml`: Defines Redis and Redis Commander services with environment variable overrides.
-   `conf/redis.conf`: Custom Redis configuration for performance tuning and persistence.

## Starting Redis

To start Redis and Redis Commander:

```
docker-compose up -d
```

## Stopping Redis

To stop the services:

```
docker-compose down
```

To remove volumes and data:

```
docker-compose down -v
```

## Accessing Redis

-   **Redis Server:** `localhost:6379`
-   **Redis Commander Web Interface:** `http://localhost:8081`

## Connecting to Redis

### Using redis-cli (if available locally)

```bash
redis-cli -h localhost -p 6379
```

### Using Docker exec

```bash
docker exec -it redis redis-cli
```

## Using Redis Commander

1. Open your browser and navigate to `http://localhost:8081`
2. The interface will automatically connect to the Redis server running on `redis:6379`
3. You can browse keys, view values, and perform Redis operations through the web interface

## Scaling the Setup

To add more Redis instances (for replication or clustering):

1. Duplicate the redis service in `docker-compose.yml`.
2. Update the following for the new instance:
    - `container_name` and `hostname` (e.g., redis-replica)
    - `ports` (e.g., 6380:6379)
    - `volumes` path (e.g., `./data/redis-replica:/data`)
3. Configure replication settings in `redis.conf` if needed.
4. Start the new instance with `docker-compose up -d redis-replica`.

## Architecture Notes

-   **Multi-Architecture Support:** Uses official Redis image, supporting `x86_64`, `arm64`, and Apple Silicon.
-   Port Mappings:
    -   Redis: `localhost:6379`
    -   Redis Commander: `localhost:8081`
-   **Persistent Data:** Stored in `./data/redis` for Redis data and AOF files.
-   **Custom Configuration:** Redis uses custom `redis.conf` file for optimized settings including:
    -   AOF persistence enabled
    -   Memory limits and eviction policies
    -   Performance tuning parameters
-   **Health Checks:** Redis includes health checks using `redis-cli ping` to ensure proper startup.
-   **Environment Control:** Most Redis and Redis Commander settings are configurable via `.env` for centralized management.
-   **Network Isolation:** All services communicate over a custom bridge network (`redis-network`).

## Environment Variables

Key environment variables (set in `.env`):

### Redis Settings

-   `REDIS_IMAGE`: Redis Docker image (e.g., `redis:7-alpine`).
-   `REDIS_MEM_LIMIT`: Memory limit for Redis container (e.g., `512m`).
-   `REDIS_CPU_LIMIT`: CPU limit for Redis container (e.g., `0.5`).

### Redis Commander Settings

-   `REDIS_UI_IMAGE`: Redis Commander Docker image (e.g., `rediscommander/redis-commander:latest`).
-   `REDIS_UI_PORT`: Port for Redis Commander web interface (e.g., `8081`).

### Performance Tuning

The Redis configuration in `conf/redis.conf` includes:

-   **Memory Management:** `maxmemory 300mb` with `allkeys-lru` eviction policy
-   **Persistence:** AOF enabled with periodic saves (900s, 300s, 60s intervals)
-   **Network:** TCP keepalive enabled, protected mode disabled for containerized environment
-   **Logging:** Debug level logging for development environments

## Redis Configuration Details

The custom `redis.conf` provides:

-   **Persistence:** AOF (Append-Only File) enabled for data durability
-   **Memory Limits:** 300MB memory limit with LRU eviction
-   **Performance:** Optimized save intervals and network settings
-   **Security:** Disabled protected mode for containerized deployment
-   **Monitoring:** Debug logging for development troubleshooting
