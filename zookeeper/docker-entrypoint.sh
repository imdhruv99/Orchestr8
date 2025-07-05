#!/bin/bash
set -e

# Default environment variables
ZOOKEEPER_MYID=${ZOOKEEPER_MYID:-1}
ZOOKEEPER_SERVERS=${ZOOKEEPER_SERVERS:-"server.1=0.0.0.0:2888:3888;2181"}
ZOOKEEPER_DATA_DIR=${ZOOKEEPER_DATA_DIR:-"/var/lib/zookeeper/data"}
ZOOKEEPER_LOG_DIR=${ZOOKEEPER_LOG_DIR:-"/var/lib/zookeeper/logs"}
ZOOKEEPER_CLIENT_PORT=${ZOOKEEPER_CLIENT_PORT:-2181}
ZOOKEEPER_TICK_TIME=${ZOOKEEPER_TICK_TIME:-2000}
ZOOKEEPER_INIT_LIMIT=${ZOOKEEPER_INIT_LIMIT:-10}
ZOOKEEPER_SYNC_LIMIT=${ZOOKEEPER_SYNC_LIMIT:-5}
ZOOKEEPER_MAX_CLIENT_CNXNS=${ZOOKEEPER_MAX_CLIENT_CNXNS:-60}

# Print configuration
cat <<EOCONF
Starting Apache Zookeeper with the following configuration:
  ZOOKEEPER_MYID=${ZOOKEEPER_MYID}
  ZOOKEEPER_SERVERS=${ZOOKEEPER_SERVERS}
  ZOOKEEPER_DATA_DIR=${ZOOKEEPER_DATA_DIR}
  ZOOKEEPER_LOG_DIR=${ZOOKEEPER_LOG_DIR}
  ZOOKEEPER_CLIENT_PORT=${ZOOKEEPER_CLIENT_PORT}
  ZOOKEEPER_TICK_TIME=${ZOOKEEPER_TICK_TIME}
  ZOOKEEPER_INIT_LIMIT=${ZOOKEEPER_INIT_LIMIT}
  ZOOKEEPER_SYNC_LIMIT=${ZOOKEEPER_SYNC_LIMIT}
  ZOOKEEPER_MAX_CLIENT_CNXNS=${ZOOKEEPER_MAX_CLIENT_CNXNS}
EOCONF

# Create necessary directories
mkdir -p "${ZOOKEEPER_DATA_DIR}" "${ZOOKEEPER_LOG_DIR}"

# Create myid file if it doesn't exist
if [ ! -f "${ZOOKEEPER_DATA_DIR}/myid" ]; then
    echo "Creating myid file with ID: ${ZOOKEEPER_MYID}"
    echo "${ZOOKEEPER_MYID}" > "${ZOOKEEPER_DATA_DIR}/myid"
fi

# Generate dynamic zoo.cfg if environment variables are provided
if [ -n "$ZOOKEEPER_SERVERS" ] || [ -n "$ZOOKEEPER_CLIENT_PORT" ]; then
    echo "Generating dynamic zoo.cfg configuration..."

    cat <<EOF > /opt/zookeeper/conf/zoo.cfg
# The number of milliseconds of each tick
tickTime=${ZOOKEEPER_TICK_TIME}

# The number of ticks that the initial synchronization phase can take
initLimit=${ZOOKEEPER_INIT_LIMIT}

# The number of ticks that can pass between sending a request and getting an acknowledgement
syncLimit=${ZOOKEEPER_SYNC_LIMIT}

# The directory where the snapshot is stored
dataDir=${ZOOKEEPER_DATA_DIR}

# The directory where the transaction logs are stored
dataLogDir=${ZOOKEEPER_LOG_DIR}

# The port at which the clients will connect
clientPort=${ZOOKEEPER_CLIENT_PORT}

# Server configuration
${ZOOKEEPER_SERVERS}

# Maximum number of client connections
maxClientCnxns=${ZOOKEEPER_MAX_CLIENT_CNXNS}

# The number of snapshots to retain in dataDir
autopurge.snapRetainCount=3

# Purge task interval in hours
autopurge.purgeInterval=1

# Enable 4lw commands (four letter word commands)
4lw.commands.whitelist=*

# Enable admin server
admin.enableServer=true
admin.serverPort=8080

# Enable JMX monitoring
jmxLocalOnly=false
jmxPort=9999

# Log level
zookeeper.root.logger=INFO, CONSOLE

# Performance tuning
clientPortAddress=0.0.0.0

# Snapshot and transaction log settings
snapCount=10000
maxSessionTimeout=40000
minSessionTimeout=4000

# Network settings
maxClientCnxnsPerHost=0

# Enable extended features
extendedTypesEnabled=true
EOF
fi

# Set up JMX monitoring
export ZOO_LOG_DIR="${ZOOKEEPER_LOG_DIR}"
export ZOO_JAVA_OPTS="-javaagent:/opt/zookeeper/jmx_prometheus_javaagent.jar=9999:/opt/zookeeper/jmx-config.yml"

# Set JVM heap options for production
export ZOO_HEAP_OPTS="-Xmx1G -Xms1G"

# Validate configuration
echo "Validating Zookeeper configuration..."
if [ ! -f "/opt/zookeeper/conf/zoo.cfg" ]; then
    echo "ERROR: zoo.cfg configuration file not found!"
    exit 1
fi

if [ ! -f "${ZOOKEEPER_DATA_DIR}/myid" ]; then
    echo "ERROR: myid file not found in ${ZOOKEEPER_DATA_DIR}!"
    exit 1
fi

echo "Configuration validation passed."

# Check if this is a fresh installation
if [ ! -d "${ZOOKEEPER_DATA_DIR}/version-2" ]; then
    echo "Fresh Zookeeper installation detected."
else
    echo "Existing Zookeeper data found."
fi

# Set proper permissions
chown -R zookeeper:zookeeper "${ZOOKEEPER_DATA_DIR}" "${ZOOKEEPER_LOG_DIR}" 2>/dev/null || true

echo "Starting Zookeeper server..."
echo "Configuration file: /opt/zookeeper/conf/zoo.cfg"
echo "Data directory: ${ZOOKEEPER_DATA_DIR}"
echo "Log directory: ${ZOOKEEPER_LOG_DIR}"

# Drop privileges if running as root
if [ "$(id -u)" = '0' ]; then
    exec su-exec zookeeper "$@"
else
    exec "$@"
fi
