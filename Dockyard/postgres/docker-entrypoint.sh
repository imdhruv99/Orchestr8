#!/bin/bash

set -e

echo "PostgreSQL entrypoint starting..."
echo "PGDATA: $PGDATA"

# Init database if empty
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Initializing PostgreSQL Database..."
    /usr/lib/postgresql/16/bin/initdb -D "$PGDATA"
    echo "PostgreSQL Database initialized successfully"
else
    echo "PostgreSQL Database found, starting server..."
fi

exec "$@"
