#!/bin/bash
set -e

echo "Jenkins entrypoint starting..."
echo "JENKINS_HOME: $JENKINS_HOME"
echo "JENKINS_VERSION: $JENKINS_VERSION"

validate_environment() {
    echo "Validating environment..."

    : "${JENKINS_HOME:?Missing JENKINS_HOME}"
    : "${JENKINS_ADMIN_USER:?Missing JENKINS_ADMIN_USER}"

    if [ -z "$JENKINS_ADMIN_PASSWORD" ] && [ -f "/run/secrets/jenkins_admin_password" ]; then
        export JENKINS_ADMIN_PASSWORD=$(< /run/secrets/jenkins_admin_password)
    fi

    if [ -z "$JENKINS_ADMIN_PASSWORD" ]; then
        echo "ERROR: JENKINS_ADMIN_PASSWORD is not set and no secret found at /run/secrets/jenkins_admin_password"
        exit 1
    fi

    echo "Environment validation passed"
}

print_configuration() {
    cat <<EOCONF
Starting Jenkins with the following configuration:
  JENKINS_VERSION=${JENKINS_VERSION}
  JENKINS_HOME=${JENKINS_HOME}
  JENKINS_HTTP_PORT=${JENKINS_HTTP_PORT}
  JENKINS_SLAVE_AGENT_PORT=${JENKINS_SLAVE_AGENT_PORT}
  JENKINS_ADMIN_USER=${JENKINS_ADMIN_USER}
  JENKINS_OPTS=${JENKINS_OPTS}
EOCONF
}

setup_jcasc() {
    echo "Setting up Configuration as Code..."

    mkdir -p "$JENKINS_HOME"

    if [ ! -f "$JENKINS_HOME/jenkins.yaml" ]; then
        cp /usr/share/jenkins/ref/jenkins.yaml "$JENKINS_HOME/"
        sed -i "s/\${JENKINS_ADMIN_USER}/$JENKINS_ADMIN_USER/g" "$JENKINS_HOME/jenkins.yaml"
        sed -i "s/\${JENKINS_ADMIN_PASSWORD}/$JENKINS_ADMIN_PASSWORD/g" "$JENKINS_HOME/jenkins.yaml"
        sed -i "s|\${JENKINS_URL}|$JENKINS_URL|g" "$JENKINS_HOME/jenkins.yaml"
        chown jenkins:jenkins "$JENKINS_HOME/jenkins.yaml"
    fi
}

setup_logging() {
    echo "Setting up logging..."
    cat > "$JENKINS_HOME/log.properties" <<EOF
handlers=java.util.logging.ConsoleHandler
jenkins.level=INFO
java.util.logging.ConsoleHandler.level=INFO
java.util.logging.ConsoleHandler.formatter=java.util.logging.SimpleFormatter
java.util.logging.SimpleFormatter.format=[%1\$tc] %4\$s: %2\$s - %5\$s %6\$s%n
EOF
    chown jenkins:jenkins "$JENKINS_HOME/log.properties"
}

init_security() {
    echo "Copying security init script..."
    mkdir -p "$JENKINS_HOME/init.groovy.d"
    cp /usr/share/jenkins/ref/init.groovy.d/security.groovy "$JENKINS_HOME/init.groovy.d/"
    chown -R jenkins:jenkins "$JENKINS_HOME/init.groovy.d"
}

set_permissions() {
    echo "Setting final permissions..."
    chown -R jenkins:jenkins "$JENKINS_HOME"
}

main() {
    echo "=== Jenkins Container Initialization ==="

    validate_environment
    print_configuration
    setup_jcasc
    setup_logging
    init_security
    set_permissions

    echo "=== Jenkins Initialization Complete ==="
    echo "Jenkins is available at $JENKINS_URL"
    echo "Admin user: $JENKINS_ADMIN_USER"

    exec "$@"
}

main "$@"
