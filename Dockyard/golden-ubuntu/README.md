# Golden Ubuntu

A **hardened, minimal Ubuntu base image** built for secure, reusable container development. This image serves as the foundation for production-ready container stacks such as PostgreSQL, Kafka, Redis, and more — all running on a secure and clean operating system layer.

## Features

-   **Security First**: Based on latest Ubuntu LTS (`22.04`) with system-level hardening
-   **Non-Root Execution**: Runs as dedicated non-root user `imdhruv99`
-   **Minimal Footprint**: Only essential packages (`bash`, `curl`, `ca-certificates`, etc.)
-   **Service Removal**: Unused services removed (`cron`, `rsyslog`, `systemd`)
-   **Hardened Permissions**: No SUID/SGID bits, secure umask (027)
-   **Core Dump Protection**: Disabled core dumps to prevent information leakage
-   **Production Ready**: Optimized for multi-stage builds and production images

## Security Features

-   Non-root execution with dedicated user
-   Disabled SUID/SGID permissions on all binaries
-   Secure default umask (027) for new files
-   Disabled core dumps to prevent data leakage
-   Removed unnecessary system services
-   Minimal attack surface with essential packages only

## Environment Variables

-   `DEBIAN_FRONTEND`: Set to noninteractive for automated builds
-   Default user: `imdhruv99` with home directory `/home/imdhruv99`

## Build & Run

### Build the Image

Multi-Platform build command and push to your docker-hub:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t <docker-hub username>/golden-ubuntu:1.0.0 --push .
```

OR for local use:

```bash
docker build -t golden-ubuntu:1.0.0 .
```

### Run the Container

Basic run command:

```bash
docker run -it --name golden-ubuntu-container <docker-hub username>/golden-ubuntu:1.0.0
```

### Advanced Usage

Interactive shell:

```bash
docker run -it --name golden-ubuntu-container <docker-hub username>/golden-ubuntu:1.0.0 /bin/bash
```

With volume mount:

```bash
docker run -it \
  --name golden-ubuntu-container \
  -v /host/path:/container/path \
  <docker-hub username>/golden-ubuntu:1.0.0
```

## Configuration

### Security Hardening

The image implements several security hardening measures:

-   **SUID/SGID Removal**: All binaries with SUID/SGID permissions have them removed
-   **Secure Umask**: Default umask set to 027 for secure file permissions
-   **Core Dump Disabled**: Prevents sensitive data leakage in crash scenarios
-   **Service Removal**: Unnecessary services removed to reduce attack surface

### Package Management

Only essential packages are installed:

-   `bash`: Shell environment
-   `curl`: HTTP client for downloads
-   `ca-certificates`: SSL/TLS certificates
-   `netbase`: Basic networking utilities
-   `tzdata`: Timezone data

## Usage as Base Image

### In Dockerfile

```dockerfile
FROM <docker-hub username>/golden-ubuntu:1.0.0

# Your application setup here
RUN apt-get update && apt-get install -y your-package

# Switch to non-root user if needed
USER imdhruv99

CMD ["your-application"]
```

### Multi-stage Builds

```dockerfile
# Build stage
FROM <docker-hub username>/golden-ubuntu:1.0.0 AS builder
# Build your application

# Final stage
FROM <docker-hub username>/golden-ubuntu:1.0.0
COPY --from=builder /app /app
CMD ["/app/your-app"]
```

## Technical Details

### Why Remove `cron`, `rsyslog`, `systemd`?

-   **`cron`**: Used for scheduling tasks in OS. In containers, we use K8s CronJobs or CI/CD tools
-   **`rsyslog`**: A logging daemon that's overkill and potentially insecure in containers
-   **`systemd`**: The init system for full OS, not needed in Docker where PID 1 is your app

### SUID/SGID Removal Command

```bash
RUN find / -path /proc -prune -o -perm /6000 -type f -exec chmod a-s {} \;
```

SUID/SGID permissions allow binaries to run with elevated privileges. Disabling them eliminates unnecessary privilege escalation paths in containers.

### Secure Umask

```bash
RUN echo "umask 027" >> /etc/profile
```

Setting a restrictive `umask` like `027` ensures new files have secure default permissions, preventing accidental data exposure.

### Core Dump Protection

```bash
RUN echo '* hard core 0' >> /etc/security/limits.conf
```

Core dumps may contain sensitive runtime data. Disabling them prevents information leakage in crash scenarios.

## File Structure

```
golden-ubuntu/
├── Dockerfile              # Main container definition
└── README.md               # Documentation
└── .dockerignore           # Excludes unnecessary files from Docker build conte
```
