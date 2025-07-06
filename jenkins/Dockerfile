FROM imdhruv99/golden-ubuntu:1.0.0

LABEL maintainer="Dhruv Prajapati"
LABEL description="Production ready Jenkins CI/CD server"

# Environment variables
ENV JENKINS_VERSION=2.426.1.3
ENV JENKINS_HOME=/var/jenkins_home
ENV JENKINS_UC=https://updates.jenkins.io/update-center.json
ENV JENKINS_UC_DOWNLOAD=https://updates.jenkins.io/download
ENV JENKINS_SLAVE_AGENT_PORT=50000
ENV JENKINS_HTTP_PORT=8080
ENV JENKINS_OPTS="-Djenkins.install.runSetupWizard=false"
ENV JENKINS_PLUGINS="workflow-aggregator,git,configuration-as-code"
ENV JENKINS_ADMIN_USER=admin
ENV JENKINS_ADMIN_PASSWORD=admin
ENV JENKINS_URL=http://localhost:8080

# Switch to root user for privileged operations
USER root

# Create jenkins user and group with unique UID/GID
RUN groupadd -g 1010 jenkins && \
    useradd -u 1010 -g jenkins -d ${JENKINS_HOME} -s /bin/bash jenkins && \
    mkdir -p ${JENKINS_HOME} && \
    chown -R jenkins:jenkins ${JENKINS_HOME} && \
    chmod 755 ${JENKINS_HOME}

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    wget \
    curl \
    gnupg2 \
    ca-certificates \
    unzip \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install Jenkins
RUN mkdir -p /usr/share/jenkins && \
    wget -q https://get.jenkins.io/war-stable/${JENKINS_VERSION}/jenkins.war -O /usr/share/jenkins/jenkins.war && \
    chmod 644 /usr/share/jenkins/jenkins.war

# Create Jenkins directories with proper permissions
RUN mkdir -p /usr/share/jenkins/ref/init.groovy.d && \
    mkdir -p /usr/share/jenkins/ref/plugins && \
    mkdir -p /var/log/jenkins && \
    chown -R jenkins:jenkins /usr/share/jenkins /var/log/jenkins

# Copy configuration files
COPY docker-entrypoint.sh /usr/local/bin/
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy

# Set proper permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown jenkins:jenkins /usr/local/bin/docker-entrypoint.sh && \
    chown jenkins:jenkins /usr/share/jenkins/ref/plugins.txt && \
    chown jenkins:jenkins /usr/share/jenkins/ref/jenkins.yaml && \
    chown jenkins:jenkins /usr/share/jenkins/ref/init.groovy.d/security.groovy

# Switch to jenkins user
USER jenkins

# Set working directory
WORKDIR ${JENKINS_HOME}

# Expose ports
EXPOSE ${JENKINS_HTTP_PORT} ${JENKINS_SLAVE_AGENT_PORT}

# Create volumes for persistent data
VOLUME [ "${JENKINS_HOME}" ]

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${JENKINS_HTTP_PORT}/login || exit 1

# Entrypoint
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
CMD [ "java", "-jar", "/usr/share/jenkins/jenkins.war" ]
