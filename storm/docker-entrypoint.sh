#!/bin/bash
set -e

# Storm environment variables
STORM_ROLE=${STORM_ROLE:-"nimbus"}  # nimbus / supervisor / ui
STORM_CONFIG_DIR="/opt/storm/conf"
STORM_LOG_DIR="/var/log/storm"
STORM_DATA_DIR="/var/lib/storm"
STORM_JMX_PORT=${STORM_JMX_PORT:-9999}

# Print startup config
echo "Starting Apache Storm node with:"
echo "  ROLE: $STORM_ROLE"
echo "  JMX PORT: $STORM_JMX_PORT"

# Create necessary directories
mkdir -p "${STORM_LOG_DIR}" "${STORM_DATA_DIR}" "${STORM_CONFIG_DIR}"

# Generate storm.yaml
cat <<EOF > "${STORM_CONFIG_DIR}/storm.yaml"
storm.zookeeper.servers:
  - "zookeeper1"
  - "zookeeper2"
  - "zookeeper3"
storm.zookeeper.port: 2181
storm.local.dir: "${STORM_DATA_DIR}"
nimbus.seeds: ["nimbus"]
supervisor.slots.ports:
  - 6700
  - 6701
  - 6702
  - 6703
ui.port: 8080
logviewer.port: 8000
storm.cluster.mode: "distributed"
storm.log.dir: "${STORM_LOG_DIR}"
storm.enable.builtin.metrics: true
EOF

# JMX Prometheus Agent
export STORM_OPTS="-Dcom.sun.management.jmxremote \
  -Dcom.sun.management.jmxremote.port=${STORM_JMX_PORT} \
  -Dcom.sun.management.jmxremote.rmi.port=${STORM_JMX_PORT} \
  -Dcom.sun.management.jmxremote.authenticate=false \
  -Dcom.sun.management.jmxremote.ssl=false \
  -Djava.rmi.server.hostname=localhost \
  -javaagent:/opt/storm/jmx_prometheus_javaagent.jar=${STORM_JMX_PORT}:/opt/storm/jmx-config.yml"

# Storm daemon command
case "$STORM_ROLE" in
  nimbus)
    exec storm nimbus
    ;;
  supervisor)
    exec storm supervisor
    ;;
  ui)
    exec storm ui
    ;;
  logviewer)
    exec storm logviewer
    ;;
  *)
    echo "Unknown STORM_ROLE: $STORM_ROLE"
    exit 1
    ;;
esac
