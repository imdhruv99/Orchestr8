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
-   **Kafka**: Apache Kafka for event streaming
-   **MongoDB**: NoSQL database with security hardening
-   **MySQL**: Relational database with production optimizations

## 🛡️ Security Features

All images in Dockyard follow these security principles:

-   **Non-root execution**: All images run as dedicated non-root users
-   **Minimal attack surface**: Only essential packages and services included
-   **Security hardening**: SUID/SGID removal, secure umask, core dump protection
-   **Regular updates**: Based on latest LTS versions with security patches
-   **Custom configurations**: Optimized for security and performance

## 🚀 Quick Start

### Using Golden Ubuntu as Base

```dockerfile
FROM imdhruv99/golden-ubuntu:1.0.0

# Your application setup
RUN apt-get update && apt-get install -y your-package

# Switch to non-root user
USER imdhruv99

CMD ["your-application"]
```

### Running PostgreSQL

```bash
# Build the image
docker build -t imdhruv99/postgres:1.0.0 ./postgres

# Run PostgreSQL
docker run -d \
  --name postgres \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  imdhruv99/postgres:1.0.0
```

## 📁 Project Structure

```
Dockyard/
├── golden-ubuntu/           # Hardened Ubuntu base image
│   ├── Dockerfile
│   ├── README.md
│   └── .dockerignore
├── postgres/               # PostgreSQL database image
│   ├── Dockerfile
│   ├── docker-entrypoint.sh
│   ├── postgresql.conf
│   ├── README.md
│   └── .dockerignore
├── README.md              # This file
├── LICENSE                # Project license
└── .gitignore
```

## 🔧 Development

### Prerequisites

-   Docker 20.10+
-   Git

### Building Images

```bash
# Build Golden Ubuntu
cd golden-ubuntu
docker build -t imdhruv99/golden-ubuntu:1.0.0 .

# Build PostgreSQL
cd ../postgres
docker build -t imdhruv99/postgres:1.0.0 .
```

### Testing Images

```bash
# Test Golden Ubuntu
docker run -it --rm imdhruv99/golden-ubuntu:1.0.0 /bin/bash

# Test PostgreSQL
docker run -d --name test-postgres -p 5432:5432 imdhruv99/postgres:1.0.0
docker exec -it test-postgres psql -U postgres
```

## 📄 License

This project is licensed under the **Dual License** model:

### For Non-Commercial Use (Free)

-   **License**: MIT License
-   **Usage**: Free for personal, educational, and non-commercial projects
-   **Attribution**: Required - must include original author attribution

### For Commercial Use (Paid)

-   **License**: Commercial License
-   **Fee**: $99 USD per commercial project/company
-   **Contact**: [dhruv.prajapati.business@gmail.com
    ](mailto:dhruv.prajapati.business@gmail.com)
-   **Terms**:
    -   One-time payment per company/organization
    -   Covers all current and future images in the Dockyard collection
    -   Includes commercial support and updates
    -   No attribution required for commercial use

### License Terms

-   **Non-Commercial**: Personal projects, education, open-source projects
-   **Commercial**: Any use in for-profit businesses, SaaS applications, commercial products
-   **Attribution**: Must include "Built with Dockyard by Dhruv Prajapati" for free usage
-   **Modifications**: Allowed under both licenses
-   **Distribution**: Allowed under both licenses

### Payment for Commercial Use

To use Dockyard images commercially, please:

1. Contact [dhruv.prajapati.business@gmail.com](mailto:dhruv.prajapati.business@gmail.com)
2. Provide company/organization details
3. Complete payment of $99 USD
4. Receive commercial license and support

## 👨‍💻 Author

**Dhruv Prajapati**

-   Email: [dhruv.prajapati.business@gmail.com](mailto:dhruv.prajapati.business@gmail.com)
-   GitHub: [@imdhruv99](https://github.com/imdhruv99)

## 🙏 Acknowledgments

-   Ubuntu team for the excellent base distribution
-   PostgreSQL community for the robust database system
-   Docker community for the containerization platform
-   All contributors and users of Dockyard

## 📞 Support

-   **Issues**: [GitHub Issues](https://github.com/imdhruv99/Dockyard/issues)
-   **Commercial Support**: [dhruv.prajapati.business@gmail.com](mailto:dhruv.prajapati.business@gmail.com)
-   **Documentation**: Check individual image README files

---
