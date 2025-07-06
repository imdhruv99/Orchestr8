# Jenkins

A production-ready, secure, and minimal Jenkins CI/CD server image built on the hardened `golden-ubuntu` base. Features dynamic plugin configuration, security hardening, and non-root execution following Dockyard security standards.

## Features

-   **Security First**: Uses non-root base image (`golden-ubuntu`) with hardened security
-   **Dynamic Plugin Management**: Configurable plugins via environment variables or mounted files
-   **Non-Root Execution**: Runs Jenkins under dedicated `jenkins` user (UID: 1000)
-   **Persistent Storage**: Stores Jenkins data at `/var/jenkins_home`
-   **Secure Permissions**: Proper file permissions and ownership isolation
-   **Multi-Platform Support**: Built for linux/amd64 and linux/arm64
-   **Health Checks**: Built-in health monitoring
-   **Plugin Security**: Automatic security updates and vulnerability scanning

## Security Features

-   Non-root execution with dedicated Jenkins user
-   Isolated Jenkins user and group (UID: 1000)
-   Secure file permissions on Jenkins home directory
-   Minimal attack surface with hardened base image
-   Plugin security scanning and updates
-   CSRF protection enabled by default
-   Secure headers configuration
-   Session management security

## Environment Variables

| Variable                 | Description                     | Default                                       |
| ------------------------ | ------------------------------- | --------------------------------------------- |
| JENKINS_VERSION          | Jenkins version                 | 2.426.1.3                                     |
| JENKINS_HOME             | Jenkins home directory          | /var/jenkins_home                             |
| JENKINS_OPTS             | Jenkins JVM options             | -Djenkins.install.runSetupWizard=false        |
| JENKINS_UC               | Update center URL               | https://updates.jenkins.io/update-center.json |
| JENKINS_UC_DOWNLOAD      | Download center URL             | https://updates.jenkins.io/download           |
| JENKINS_SLAVE_AGENT_PORT | Agent connection port           | 50000                                         |
| JENKINS_HTTP_PORT        | HTTP port                       | 8080                                          |
| JENKINS_PLUGINS          | Comma-separated list of plugins | workflow-aggregator,git,configuration-as-code |
| JENKINS_ADMIN_USER       | Admin username                  | admin                                         |
| JENKINS_ADMIN_PASSWORD   | Admin password                  | admin                                         |
| JENKINS_URL              | Jenkins URL                     | http://localhost:8080                         |

## Build & Run

### Build the Image

Multi-Platform build command and push to your docker-hub:

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t <docker-hub username>/jenkins:1.0.0 --push .
```

OR for local use:

```bash
docker build -t jenkins:1.0.0 .
```

### Run the Container

Basic run command:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  <docker-hub username>/jenkins:1.0.0
```

### Advanced Usage

With custom environment variables:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -e JENKINS_ADMIN_USER=admin \
  -e JENKINS_ADMIN_PASSWORD=secure_password \
  -e JENKINS_PLUGINS="workflow-aggregator,git,configuration-as-code,blueocean" \
  -v jenkins_home:/var/jenkins_home \
  <docker-hub username>/jenkins:1.0.0
```

With Docker Compose:

```yaml
version: "3.8"

services:
    jenkins:
        image: <docker-hub username>/jenkins:1.0.0
        container_name: jenkins
        environment:
            - JENKINS_ADMIN_USER=admin
            - JENKINS_ADMIN_PASSWORD=secure_password
            - JENKINS_PLUGINS=workflow-aggregator,git,configuration-as-code,blueocean
        ports:
            - "8080:8080"
            - "50000:50000"
        volumes:
            - jenkins_home:/var/jenkins_home
        healthcheck:
            test: ["CMD", "curl", "-f", "http://localhost:8080/login"]
            interval: 30s
            timeout: 10s
            retries: 3
            start_period: 60s

volumes:
    jenkins_home:
```

## Plugin Management

### Dynamic Plugin Installation

The image supports dynamic plugin installation through environment variables:

```bash
# Install specific plugins
-e JENKINS_PLUGINS="workflow-aggregator,git,configuration-as-code,blueocean,docker-workflow"

# Install plugins from file
-v /path/to/plugins.txt:/var/jenkins_home/plugins.txt
```

### Plugin Configuration File

Create a `plugins.txt` file with your required plugins:

```txt
workflow-aggregator:latest
git:latest
configuration-as-code:latest
blueocean:latest
docker-workflow:latest
pipeline-stage-view:latest
```

### Plugin Security

-   Automatic security updates for plugins
-   Vulnerability scanning for installed plugins
-   Plugin compatibility checks
-   Secure plugin download from official sources

## Configuration

### Jenkins Configuration as Code

The image supports Configuration as Code (JCasC) for automated setup:

```bash
# Mount configuration files
-v /path/to/jenkins.yaml:/var/jenkins_home/jenkins.yaml
```

Example `jenkins.yaml`:

```yaml
jenkins:
    securityRealm:
        local:
            allowsSignup: false
            users:
                - id: "admin"
                  password: "${JENKINS_ADMIN_PASSWORD}"
    authorizationStrategy:
        globalMatrix:
            permissions:
                - "Overall/Administer:admin"
    systemMessage: "Jenkins configured automatically by Configuration as Code plugin"
    numExecutors: 2
    scmCheckoutRetryCount: 3
    mode: NORMAL
    labelString: ""

tool:
    git:
        installations:
            - name: "Default"
              home: "git"

unclassified:
    location:
        url: http://localhost:8080/
```

### Security Configuration

The image includes several security enhancements:

-   CSRF protection enabled
-   Secure headers configuration
-   Session timeout settings
-   Plugin security policies
-   User authentication hardening

## Connecting to Jenkins

### Web Interface

Access Jenkins at `http://localhost:8080` (or your configured URL)

### Agent Connections

Jenkins agents can connect on port 50000:

```bash
# From agent machine
java -jar agent.jar -jnlpUrl http://jenkins:8080/computer/agent/slave-agent.jnlp -secret <secret>
```

### API Access

Jenkins REST API is available at `http://localhost:8080/api/`

## Monitoring

### Health Check

The container includes a health check that verifies Jenkins is responding:

```bash
curl -f http://localhost:8080/login
```

### Logs

View Jenkins logs:

```bash
docker logs jenkins
```

### Metrics

Jenkins provides built-in metrics and monitoring capabilities through various plugins.

## Backup and Restore

### Backup Jenkins Data

```bash
# Create backup
docker run --rm --volumes-from jenkins -v $(pwd):/backup ubuntu tar cvf /backup/jenkins-backup.tar /var/jenkins_home
```

### Restore Jenkins Data

```bash
# Restore from backup
docker run --rm --volumes-from jenkins -v $(pwd):/backup ubuntu tar xvf /backup/jenkins-backup.tar
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure proper ownership of mounted volumes
2. **Plugin Installation Failures**: Check network connectivity and plugin compatibility
3. **Memory Issues**: Adjust JVM heap size via `JENKINS_OPTS`

### Debug Mode

Run Jenkins in debug mode:

```bash
docker run -it --rm \
  -p 8080:8080 \
  -e JENKINS_OPTS="-Djenkins.install.runSetupWizard=false -Djava.util.logging.config.file=/var/jenkins_home/log.properties" \
  <docker-hub username>/jenkins:1.0.0
```

## File Structure

```
jenkins/
├── Dockerfile              # Main container definition
├── docker-entrypoint.sh    # Container entrypoint script
├── plugins.txt             # Default plugins list
├── jenkins.yaml            # Default Configuration as Code
├── security.groovy         # Security configuration script
├── README.md               # Documentation
└── .dockerignore           # Excludes unnecessary files from Docker build context
```

## Security Best Practices

1. **Use Strong Passwords**: Always set secure admin passwords
2. **Regular Updates**: Keep Jenkins and plugins updated
3. **Network Security**: Use reverse proxies and HTTPS in production
4. **Access Control**: Implement proper user authentication and authorization
5. **Backup Strategy**: Regular backups of Jenkins data
6. **Monitoring**: Monitor Jenkins health and performance
7. **Plugin Management**: Only install necessary and trusted plugins
