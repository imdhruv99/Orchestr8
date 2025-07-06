import jenkins.model.*
import hudson.security.*
import hudson.util.*
import jenkins.security.s2m.AdminWhitelistRule
import hudson.security.csrf.DefaultCrumbIssuer
import hudson.security.HudsonPrivateSecurityRealm
import hudson.security.GlobalMatrixAuthorizationStrategy

def instance = Jenkins.getInstance()

// Disable CLI over TCP
instance.getDescriptor("jenkins.CLI").get().enabled = false

// Enable CSRF protection
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))

// Set security realm to local users
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
instance.setSecurityRealm(hudsonRealm)

// Set authorization strategy
def strategy = new GlobalMatrixAuthorizationStrategy()
strategy.add(Jenkins.ADMINISTER, "admin")
strategy.add(Jenkins.READ, "authenticated")
instance.setAuthorizationStrategy(strategy)

// Disable script console for non-admins
instance.getDescriptor("jenkins.model.Jenkins").get().setDisableUsageStatistics(true)

// Set up security headers
instance.setSlaveAgentPort(50000)
instance.setSlaveAgentPortEnforce(true)

// Disable JNLP4 protocol (use JNLP3)
instance.getDescriptor("jenkins.slaves.JnlpSlaveAgentProtocol3").get().enabled = true
instance.getDescriptor("jenkins.slaves.JnlpSlaveAgentProtocol4").get().enabled = false

// Enable agent to master security
instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)

// Save configuration
instance.save()
