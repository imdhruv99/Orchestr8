FROM ubuntu:22.04

LABEL maintainer="Dhruv Prajapati"
LABEL description="Hardened, minimal ubuntu base image for secure container builds"

# Setup non interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update, Upgrade & Install
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    bash \
    curl \
    ca-certificates \
    netbase \
    tzdata && \
    apt-get purge -y \
    cron \
    rsyslog \
    systemd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Disable SUID/SGID bits
RUN find / -path /proc -prune -o -perm /6000 -type f -exec chmod a-s {} \;

# Set secure umask
RUN echo "umask 027" >> /etc/profile

# Disable core dumps
RUN echo '* hard core 0' >> /etc/security/limits.conf

# Create non-root user and switch to non-root user
RUN useradd -m -s /bin/bash imdhruv99
USER imdhruv99

# Default working directory
WORKDIR /home/imdhruv99

# Prevent container to run by default as root user
ENTRYPOINT [ "/bin/bash" ]
