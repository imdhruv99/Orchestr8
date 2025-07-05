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
Starting Apache ZooKeeper with the following configuration:
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

# Create myid file if not exists
if [ ! -f "${ZOOKEEPER_DATA_DIR}/myid" ]; then
  echo "Creating myid file with ID: ${ZOOKEEPER_MYID}"
  echo "${ZOOKEEPER_MYID}" > "${ZOOKEEPER_DATA_DIR}/myid"
fi

# Generate zoo.cfg
cat <<EOF > /opt/zookeeper/conf/zoo.cfg
tickTime=${ZOOKEEPER_TICK_TIME}
initLimit=${ZOOKEEPER_INIT_LIMIT}
syncLimit=${ZOOKEEPER_SYNC_LIMIT}
dataDir=${ZOOKEEPER_DATA_DIR}
dataLogDir=${ZOOKEEPER_LOG_DIR}
clientPort=${ZOOKEEPER_CLIENT_PORT}
${ZOOKEEPER_SERVERS}
maxClientCnxns=${ZOOKEEPER_MAX_CLIENT_CNXNS}
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
4lw.commands.whitelist=*
admin.enableServer=true
admin.serverPort=8080
clientPortAddress=0.0.0.0
snapCount=10000
maxSessionTimeout=40000
minSessionTimeout=4000
maxClientCnxnsPerHost=0
extendedTypesEnabled=true

# Native Prometheus Metrics
metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
metricsProvider.httpPort=9999
metricsProvider.exportJvmInfo=true
EOF

# Final check
if [ ! -f "/opt/zookeeper/conf/zoo.cfg" ] || [ ! -f "${ZOOKEEPER_DATA_DIR}/myid" ]; then
  echo "ERROR: Missing required configuration."
  exit 1
fi

# Start ZooKeeper
if [ "$#" -eq 0 ]; then
  CMD=("zkServer.sh" "start-foreground")
else
  CMD=("$@")
fi

if [ "$(id -u)" = '0' ]; then
  exec su-exec zookeeper "${CMD[@]}"
else
  exec "${CMD[@]}"
fi
