FROM imdhruv99/golden-ubuntu:1.0.0

LABEL maintainer="Dhruv Prajapati"
LABEL description="Production ready Jenkins CI/CD server"

# Jenkins environment configuration
ENV JENKINS_VERSION=2.426.1
ENV JENKINS_HOME=/var/jenkins_home
ENV JENKINS_HTTP_PORT=8080
ENV JENKINS_SLAVE_AGENT_PORT=50000
ENV JENKINS_UC=https://updates.jenkins.io/update-center.json
ENV JENKINS_UC_DOWNLOAD=https://updates.jenkins.io/download
ENV REF_DIR=/usr/share/jenkins/ref
ENV JENKINS_OPTS="-Djenkins.install.runSetupWizard=false"

# Switch to root user for privileged operations
USER root

# Create Jenkins user and group
RUN groupadd -g 1010 jenkins && \
    useradd -u 1010 -g jenkins -d ${JENKINS_HOME} -s /bin/bash jenkins && \
    mkdir -p ${JENKINS_HOME} && \
    chown -R jenkins:jenkins ${JENKINS_HOME}

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-17-jre-headless \
    curl \
    wget \
    gnupg2 \
    git \
    unzip \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Download Jenkins WAR
RUN mkdir -p /usr/share/jenkins && \
    wget -q https://get.jenkins.io/war-stable/${JENKINS_VERSION}/jenkins.war -O /usr/share/jenkins/jenkins.war && \
    chmod 644 /usr/share/jenkins/jenkins.war

# Download Plugin Manager CLI
RUN curl -fsSL https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.12.7/jenkins-plugin-manager-2.12.7.jar -o /usr/share/jenkins/plugin-manager.jar

# Create Jenkins reference directory
RUN mkdir -p ${REF_DIR}/plugins ${REF_DIR}/init.groovy.d && \
    mkdir -p /var/log/jenkins && \
    chown -R jenkins:jenkins /usr/share/jenkins /var/log/jenkins

# Copy configuration files into image
COPY docker-entrypoint.sh /usr/local/bin/
COPY plugins.txt ${REF_DIR}/plugins.txt
COPY jenkins.yaml ${REF_DIR}/jenkins.yaml
COPY security.groovy ${REF_DIR}/init.groovy.d/security.groovy

# Set correct permissions
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chown jenkins:jenkins /usr/local/bin/docker-entrypoint.sh && \
    chown jenkins:jenkins ${REF_DIR}/plugins.txt ${REF_DIR}/jenkins.yaml ${REF_DIR}/init.groovy.d/security.groovy

# Pre-install plugins using Plugin Manager CLI
RUN java -jar /usr/share/jenkins/plugin-manager.jar \
    --war /usr/share/jenkins/jenkins.war \
    --plugin-file ${REF_DIR}/plugins.txt \
    --plugin-dir ${REF_DIR}/plugins \
    --verbose

# Set working directory
WORKDIR ${JENKINS_HOME}

# Set permissions again (ensure JCasC is owned by Jenkins user)
RUN chown -R jenkins:jenkins ${JENKINS_HOME}

# Switch to Jenkins user
USER jenkins

# Expose ports
EXPOSE ${JENKINS_HTTP_PORT} ${JENKINS_SLAVE_AGENT_PORT}

# Volumes
VOLUME ["${JENKINS_HOME}"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${JENKINS_HTTP_PORT}/login || exit 1

# Entrypoint and default CMD
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["java", "-Djava.util.logging.config.file=$JENKINS_HOME/log.properties", "-jar", "/usr/share/jenkins/jenkins.war"]
