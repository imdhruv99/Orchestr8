#!/bin/bash
set -e

echo "Jenkins entrypoint starting..."
echo "JENKINS_HOME: $JENKINS_HOME"
echo "JENKINS_VERSION: $JENKINS_VERSION"

# Function to install plugins
install_plugins() {
    local plugins_file="$1"
    local plugins_list="$2"

    if [ -f "$plugins_file" ]; then
        echo "Installing plugins from file: $plugins_file"
        while IFS= read -r line || [ -n "$line" ]; do
            # Skip comments and empty lines
            [[ $line =~ ^[[:space:]]*# ]] && continue
            [[ -z "${line// }" ]] && continue

            # Extract plugin name and version
            plugin_name=$(echo "$line" | cut -d: -f1)
            plugin_version=$(echo "$line" | cut -d: -f2)

            if [ "$plugin_version" = "latest" ]; then
                echo "Installing plugin: $plugin_name (latest)"
                java -jar /usr/share/jenkins/jenkins.war --pluginDownloadTimeout=300 -Djenkins.install.runSetupWizard=false --installPlugin "$plugin_name"
            else
                echo "Installing plugin: $plugin_name ($plugin_version)"
                java -jar /usr/share/jenkins/jenkins.war --pluginDownloadTimeout=300 -Djenkins.install.runSetupWizard=false --installPlugin "$plugin_name:$plugin_version"
            fi
        done < "$plugins_file"
    elif [ -n "$plugins_list" ]; then
        echo "Installing plugins from environment variable: $plugins_list"
        IFS=',' read -ra PLUGINS <<< "$plugins_list"
        for plugin in "${PLUGINS[@]}"; do
            plugin=$(echo "$plugin" | xargs)  # Trim whitespace
            if [ -n "$plugin" ]; then
                echo "Installing plugin: $plugin"
                java -jar /usr/share/jenkins/jenkins.war --pluginDownloadTimeout=300 -Djenkins.install.runSetupWizard=false --installPlugin "$plugin"
            fi
        done
    fi
}

# Function to setup security configuration
setup_security() {
    echo "Setting up security configuration..."

    # Create security configuration directory if it doesn't exist
    mkdir -p "$JENKINS_HOME/init.groovy.d"

    # Copy security configuration if it doesn't exist
    if [ ! -f "$JENKINS_HOME/init.groovy.d/security.groovy" ]; then
        cp /usr/share/jenkins/ref/init.groovy.d/security.groovy "$JENKINS_HOME/init.groovy.d/"
        chown jenkins:jenkins "$JENKINS_HOME/init.groovy.d/security.groovy"
    fi

    # Create Jenkins configuration directory
    mkdir -p "$JENKINS_HOME"

    # Set proper permissions
    chown -R jenkins:jenkins "$JENKINS_HOME"
    chmod 755 "$JENKINS_HOME"
}

# Function to setup Configuration as Code
setup_configuration_as_code() {
    echo "Setting up Configuration as Code..."

    # Create configuration directory
    mkdir -p "$JENKINS_HOME"

    # Copy default configuration if it doesn't exist
    if [ ! -f "$JENKINS_HOME/jenkins.yaml" ]; then
        cp /usr/share/jenkins/ref/jenkins.yaml "$JENKINS_HOME/"
        chown jenkins:jenkins "$JENKINS_HOME/jenkins.yaml"

        # Replace environment variables in configuration
        sed -i "s/\${JENKINS_ADMIN_PASSWORD}/$JENKINS_ADMIN_PASSWORD/g" "$JENKINS_HOME/jenkins.yaml"
        sed -i "s/\${JENKINS_ADMIN_USER}/$JENKINS_ADMIN_USER/g" "$JENKINS_HOME/jenkins.yaml"
        sed -i "s|\${JENKINS_URL}|$JENKINS_URL|g" "$JENKINS_HOME/jenkins.yaml"
    fi
}

# Function to create Jenkins configuration
create_jenkins_config() {
    echo "Creating Jenkins configuration..."

    # Create Jenkins configuration directory
    mkdir -p "$JENKINS_HOME"

    # Create basic Jenkins configuration if it doesn't exist
    if [ ! -f "$JENKINS_HOME/config.xml" ]; then
        cat > "$JENKINS_HOME/config.xml" << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<config>
  <numExecutors>2</numExecutors>
  <mode>NORMAL</mode>
  <useSecurity>true</useSecurity>
  <authorizationStrategy class="hudson.security.GlobalMatrixAuthorizationStrategy">
    <permission>hudson.model.Hudson.Administer:admin</permission>
    <permission>hudson.model.Hudson.Read:authenticated</permission>
  </authorizationStrategy>
  <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
    <disableSignup>true</disableSignup>
  </securityRealm>
  <disableRememberMe>false</disableRememberMe>
  <projectNamingStrategy class="jenkins.model.ProjectNamingStrategy$DefaultProjectNamingStrategy"/>
  <workspaceDir>${JENKINS_HOME}/workspace/${ITEM_FULL_NAME}</workspaceDir>
  <buildsDir>${ITEM_ROOTDIR}/builds</buildsDir>
  <markupFormatter class="hudson.markup.EscapedMarkupFormatter"/>
  <jdks/>
  <viewsTabBar class="hudson.views.DefaultViewsTabBar"/>
  <myViewsTabBar class="hudson.views.DefaultMyViewsTabBar"/>
  <clouds/>
  <scmCheckoutRetryCount>3</scmCheckoutRetryCount>
  <views>
    <hudson.model.AllView>
      <owner class="hudson" reference="../../.."/>
      <name>all</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
      <properties class="hudson.model.View$PropertyList"/>
    </hudson.model.AllView>
  </views>
  <primaryView>all</primaryView>
  <slaveAgentPort>50000</slaveAgentPort>
  <label></label>
  <nodeProperties/>
  <globalNodeProperties/>
</config>
EOF
        chown jenkins:jenkins "$JENKINS_HOME/config.xml"
    fi
}

# Function to create admin user
create_admin_user() {
    echo "Creating admin user..."

    # Create users directory
    mkdir -p "$JENKINS_HOME/users/$JENKINS_ADMIN_USER"

    # Create user configuration
    cat > "$JENKINS_HOME/users/$JENKINS_ADMIN_USER/config.xml" << EOF
<?xml version='1.1' encoding='UTF-8'?>
<user>
  <fullName>$JENKINS_ADMIN_USER</fullName>
  <description>Jenkins Administrator</description>
  <properties>
    <hudson.model.MyViewsProperty>
      <views>
        <hudson.model.AllView>
          <owner class="hudson.model.MyViewsProperty" reference=".."/>
          <name>all</name>
          <filterExecutors>false</filterExecutors>
          <filterQueue>false</filterQueue>
          <properties class="hudson.model.View\$PropertyList"/>
        </hudson.model.AllView>
      </views>
    </hudson.model.MyViewsProperty>
    <hudson.model.PaneStatusProperties>
      <collapsed>false</collapsed>
    </hudson.model.PaneStatusProperties>
    <hudson.search.UserSearchProperty>
      <insensitiveSearch>false</insensitiveSearch>
    </hudson.search.UserSearchProperty>
    <hudson.security.HudsonPrivateSecurityRealm_-Details>
      <passwordHash>#jbcrypt:\$(2a)\$10\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi</passwordHash>
    </hudson.security.HudsonPrivateSecurityRealm_-Details>
  </properties>
</user>
EOF
    chown -R jenkins:jenkins "$JENKINS_HOME/users"
}

# Function to setup logging
setup_logging() {
    echo "Setting up logging configuration..."

    # Create logging configuration
    cat > "$JENKINS_HOME/log.properties" << 'EOF'
handlers=java.util.logging.ConsoleHandler
jenkins.level=INFO
java.util.logging.ConsoleHandler.level=INFO
java.util.logging.ConsoleHandler.formatter=java.util.logging.SimpleFormatter
java.util.logging.SimpleFormatter.format=[%1$tc] %4$s: %2$s - %5$s %6$s%n
EOF
    chown jenkins:jenkins "$JENKINS_HOME/log.properties"
}

# Function to validate environment
validate_environment() {
    echo "Validating environment variables..."

    # Check required environment variables
    if [ -z "$JENKINS_HOME" ]; then
        echo "ERROR: JENKINS_HOME is not set"
        exit 1
    fi

    if [ -z "$JENKINS_ADMIN_USER" ]; then
        echo "ERROR: JENKINS_ADMIN_USER is not set"
        exit 1
    fi

    if [ -z "$JENKINS_ADMIN_PASSWORD" ]; then
        echo "ERROR: JENKINS_ADMIN_PASSWORD is not set"
        exit 1
    fi

    echo "Environment validation passed"
}

# Function to print configuration
print_configuration() {
    cat <<EOCONF
Starting Jenkins with the following configuration:
  JENKINS_VERSION=${JENKINS_VERSION}
  JENKINS_HOME=${JENKINS_HOME}
  JENKINS_HTTP_PORT=${JENKINS_HTTP_PORT}
  JENKINS_SLAVE_AGENT_PORT=${JENKINS_SLAVE_AGENT_PORT}
  JENKINS_ADMIN_USER=${JENKINS_ADMIN_USER}
  JENKINS_PLUGINS=${JENKINS_PLUGINS}
  JENKINS_OPTS=${JENKINS_OPTS}
EOCONF
}

# Main execution
main() {
    echo "=== Jenkins Container Initialization ==="

    # Validate environment
    validate_environment

    # Print configuration
    print_configuration

    # Setup security
    setup_security

    # Setup Configuration as Code
    setup_configuration_as_code

    # Create Jenkins configuration
    create_jenkins_config

    # Create admin user
    create_admin_user

    # Setup logging
    setup_logging

    # Install plugins if Jenkins is not already initialized
    if [ ! -f "$JENKINS_HOME/config.xml" ] || [ ! -s "$JENKINS_HOME/config.xml" ]; then
        echo "Jenkins not initialized, installing plugins..."
        install_plugins "/usr/share/jenkins/ref/plugins.txt" "$JENKINS_PLUGINS"
    else
        echo "Jenkins already initialized, skipping plugin installation"
    fi

    # Set final permissions
    chown -R jenkins:jenkins "$JENKINS_HOME"

    echo "=== Jenkins Container Initialization Complete ==="
    echo "Jenkins will be available at: $JENKINS_URL"
    echo "Admin user: $JENKINS_ADMIN_USER"

    # Execute the main command
    exec "$@"
}

# Run main function
main "$@"
