# Dockyard

A curated collection of production-ready, secure, and reusable Docker images for modern infrastructure stacks. Built with security-first principles and optimized for production deployments.

## 🚀 Overview

Dockyard provides hardened, secure Docker images that serve as the foundation for modern containerized applications. Each image is built with security best practices, minimal attack surfaces, and production-ready configurations.

## 📦 Available Images

### Base Image

-   **[Golden Ubuntu](./golden-ubuntu/)**: Hardened Ubuntu 22.04 base image with security hardening, non-root execution, and minimal footprint
    -   Security-first approach with SUID/SGID removal
    -   Non-root user execution (`imdhruv99`)
    -   Minimal essential packages only (`bash`, `curl`, `ca-certificates`)
    -   Core dump protection and secure umask (027)
    -   Removed unnecessary services (`cron`, `rsyslog`, `systemd`)
    -   Production-ready foundation for other images

### Database Images

-   **[PostgreSQL](./postgres/)**: Production-ready PostgreSQL 16 image built on Golden Ubuntu
    -   Secure database configuration with custom `postgresql.conf`
    -   Dedicated postgres user (UID: 999) with isolated ownership
    -   Secure file permissions (700 on data directory)
    -   Persistent data storage at `/var/lib/postgresql/data`
    -   Multi-platform support (linux/amd64, linux/arm64)

### Big Data Images

-   **[Apache Kafka](./kafka/)**: Production-ready Kafka image with KRaft mode (no Zookeeper)
    -   KRaft consensus mode for simplified deployment
    -   Dynamic configuration via environment variables
    -   Non-root execution (runs as `kafka` user)
    -   JMX Exporter for Prometheus metrics monitoring
    -   Support for single-node and multi-broker cluster setups
    -   Persistent data storage at `/var/lib/kafka/data`
    -   Multi-platform support (linux/amd64, linux/arm64)

### Coming Soon

-   **Redis**: Secure Redis image for caching and session storage
-   **MongoDB**: NoSQL database with security hardening
-   **MySQL**: Relational database with production optimizations

## 🛡️ Security Features

All images in Dockyard follow these security principles:

-   **Non-root execution**: All images run as dedicated non-root users
-   **Minimal attack surface**: Only essential packages and services included
-   **Security hardening**: SUID/SGID removal, secure umask, core dump protection
-   **Regular updates**: Based on latest LTS versions with security patches
-   **Custom configurations**: Optimized for security and performance

## 🛠 Multi-Platform Docker Build with `buildx`

To build and push a multi-platform Docker image (e.g., for linux/amd64 and linux/arm64), follow these steps:

1. Create and use a new buildx builder

    ```
    docker buildx create --name multi-platform-build-container --use
    docker buildx inspect --bootstrap
    ```

2. Enable QEMU emulation (if not already set up)

    ```
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    ```

3. If you are building multi-platform image from WSL or windows, do not forget to convert `docker-entrypoint.sh` into unix

    ```
    dos2unix docker-entrypoint.sh
    ```

4. Build and push the multi-platform image

    ```
    docker buildx build --platform linux/amd64,linux/arm64 -t <IMAGE NAME>:1.0.0 .
    ```

5. To remove existing one

    ```
    docker buildx rm multi-platform-build-container
    ```
