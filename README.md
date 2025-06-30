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

### Streaming & Messaging Images

-   **[Apache Kafka](./kafka/)**: Production-ready Apache Kafka 3.9.0 image with KRaft mode
    -   No Zookeeper dependency (KRaft mode)
    -   Dynamic configuration via environment variables
    -   JMX monitoring with Prometheus metrics
    -   Multi-broker cluster support
    -   Persistent data storage
    -   Built-in health checks

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

## 👨‍💻 Author

**Dhruv Prajapati**

-   Email: [dhruv.prajapati.business@gmail.com](mailto:dhruv.prajapati.business@gmail.com)
-   GitHub: [@imdhruv99](https://github.com/imdhruv99)

---
