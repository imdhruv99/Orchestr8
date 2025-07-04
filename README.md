# Dockyard

A curated collection of production-ready, secure, and reusable Docker images for modern infrastructure stacks. Built with security-first principles and optimized for production deployments.

## 🚀 Overview

Dockyard provides hardened, secure Docker images that serve as the foundation for modern containerized applications. Each image is built with security best practices, minimal attack surfaces, and production-ready configurations.

## 📦 Available Images

### Base Images

-   **[Golden Ubuntu](./golden-ubuntu/)**: Hardened Ubuntu 22.04 base image with security hardening, non-root execution, and minimal footprint
    -   Security-first approach with SUID/SGID removal
    -   Non-root user execution
    -   Minimal essential packages only
    -   Production-ready foundation for other images

### Database Images

-   **[PostgreSQL](./postgres/)**: Production-ready PostgreSQL 16 image built on Golden Ubuntu
    -   Secure database configuration
    -   Dedicated postgres user
    -   Custom PostgreSQL configuration
    -   Persistent data storage

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

3. Build and push the multi-platform image

    ```
    docker buildx build --platform linux/amd64,linux/arm64 -t <IMAGE NAME>:1.0.0 .
    ```

## 👨‍💻 Author

**Dhruv Prajapati**

-   Email: [dhruv.prajapati.business@gmail.com](mailto:dhruv.prajapati.business@gmail.com)
-   GitHub: [@imdhruv99](https://github.com/imdhruv99)

---
