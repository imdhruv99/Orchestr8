#!/bin/bash
set -e

# Dynamic parameters
KAFKA_NODE_ID=${KAFKA_NODE_ID:-1}
KAFKA_PROCESS_ROLES=${KAFKA_PROCESS_ROLES:-"broker,controller"}
KAFKA_CONTROLLER_QUORUM_VOTERS=${KAFKA_CONTROLLER_QUORUM_VOTERS:-"1@localhost:9093"}
KAFKA_LISTENERS=${KAFKA_LISTENERS:-"PLAINTEXT://:9092,CONTROLLER://:9093"}
KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP:-"PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT"}
KAFKA_ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS:-"PLAINTEXT://localhost:9092"}
KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS:-"/var/lib/kafka/logs"}
KAFKA_INTER_BROKER_LISTENER_NAME=${KAFKA_INTER_BROKER_LISTENER_NAME:-"PLAINTEXT"}

# Print config
cat <<EOCONF
Starting Apache Kafka with the following configuration:
  KAFKA_NODE_ID=${KAFKA_NODE_ID}
  KAFKA_PROCESS_ROLES=${KAFKA_PROCESS_ROLES}
  KAFKA_CONTROLLER_QUORUM_VOTERS=${KAFKA_CONTROLLER_QUORUM_VOTERS}
  KAFKA_LISTENERS=${KAFKA_LISTENERS}
  KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP}
  KAFKA_ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS}
  KAFKA_LOG_DIRS=${KAFKA_LOG_DIRS}
  KAFKA_INTER_BROKER_LISTENER_NAME=${KAFKA_INTER_BROKER_LISTENER_NAME}
EOCONF

mkdir -p "${KAFKA_LOG_DIRS}"

cat <<EOF > /opt/kafka/config/server.properties
##### Basic Configuration #####
node.id=${KAFKA_NODE_ID}
process.roles=${KAFKA_PROCESS_ROLES}
controller.quorum.voters=${KAFKA_CONTROLLER_QUORUM_VOTERS}

###### Listener Configuration #####
listeners=${KAFKA_LISTENERS}
listener.security.protocol.map=${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP}
advertised.listeners=${KAFKA_ADVERTISED_LISTENERS}

###### Socket Configuration #####
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600

###### Log Configuration #####
log.dirs=${KAFKA_LOG_DIRS}
num.partitions=3
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.retention.bytes=-1
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000

###### Topic Configuration #####
auto.create.topics.enable=true
delete.topic.enable=true
default.replication.factor=1
min.insync.replicas=1
log.cleanup.policy=delete
log.cleaner.enable=true
log.cleaner.threads=1
log.cleaner.dedupe.buffer.size=134217728
log.cleaner.io.buffer.size=524288
log.cleaner.io.buffer.load.factor=0.9
log.cleaner.backoff.ms=15000
log.cleaner.min.cleanable.ratio=0.5
log.cleaner.delete.retention.ms=86400000
compression.type=producer
log.message.format.version=3.0-IV1
log.message.timestamp.type=CreateTime
log.segment.delete.delay.ms=60000
log.index.size.max.bytes=10485760
log.index.interval.bytes=4096
log.flush.interval.messages=9223372036854775807
log.flush.interval.ms=9223372036854775807
log.flush.scheduler.interval.ms=9223372036854775807

###### Performance Tuning #####
replica.fetch.max.bytes=1048576
replica.fetch.min.bytes=1
replica.fetch.wait.max.ms=500
replica.lag.time.max.ms=10000
message.max.bytes=1000012
replica.socket.receive.buffer.bytes=65536
replica.socket.send.buffer.bytes=65536

###### Security and Monitoring #####
metric.reporters=
metrics.num.samples=2
metrics.sample.window.ms=30000
metrics.recording.level=INFO

###### Advanced Configuration #####
controller.listener.names=CONTROLLER
inter.broker.listener.name=${KAFKA_INTER_BROKER_LISTENER_NAME}

group.initial.rebalance.delay.ms=0
group.min.session.timeout.ms=6000
group.max.session.timeout.ms=300000
EOF

# Format storage for KRaft mode if needed
if [[ -n "$KAFKA_CLUSTER_ID" && ! -f "$KAFKA_LOG_DIRS/meta.properties" ]]; then
  echo "Formatting storage for KRaft mode with cluster ID: $KAFKA_CLUSTER_ID"
  /opt/kafka/bin/kafka-storage.sh format -t "$KAFKA_CLUSTER_ID" -c /opt/kafka/config/server.properties --ignore-formatted
fi

# Setup Prometheus JMX Exporter (do NOT also use built-in JMX agent)
export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"
export KAFKA_OPTS="-javaagent:/opt/kafka/jmx_prometheus_javaagent.jar=9999:/opt/kafka/jmx-config.yml"

# Drop privileges if running as root
if [ "$(id -u)" = '0' ]; then
  exec su-exec kafka "$@"
else
  exec "$@"
fi
