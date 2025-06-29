FROM imdhruv99/golden-ubuntu:1.0.0

LABEL maintainer="Dhruv Prajapati"
LABEL description="Production ready PostgreSQL image"

ENV POSTGRES_VERSION=16
ENV PATH="/usr/lib/postgresql/${POSTGRES_VERSION}/bin:$PATH"
ENV PGDATA="/var/lib/postgresql/data"

# Switch to root user for privileged operations
USER root

# Create a user and Group
RUN groupadd -r postgres && \
    useradd -r -g postgres -d /var/lib/postgresql -s /bin/bash postgres && \
    mkdir -p /var/lib/postgresql && \
    chown -R postgres:postgres /var/lib/postgresql && \
    chmod 700 /var/lib/postgresql

# Install PostgreSQL
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gnupg2 \
    ca-certificates \
    lsb-release && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg && \
    apt-get update && \
    apt-get install -y postgresql-${POSTGRES_VERSION} postgresql-client-${POSTGRES_VERSION} postgresql-contrib-${POSTGRES_VERSION} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create data directory with proper permissions
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql/data && \
    chmod 700 /var/lib/postgresql/data

# Copy configs and entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
COPY postgresql.conf /etc/postgresql/postgresql.conf

RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown postgres:postgres /etc/postgresql/postgresql.conf /usr/local/bin/docker-entrypoint.sh

# Switch to postgres user
USER postgres

VOLUME [ "/var/lib/postgresql/data" ]

EXPOSE 5432

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "postgres", "-c", "config_file=/etc/postgresql/postgresql.conf" ]
