FROM --platform=linux/amd64 jenkins/jenkins:2.462.3-jdk17

# Switch to root user to install plugins and configure Jenkins
USER root

# Install necessary packages
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Copy plugins list and install plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Create directory for JCasC configuration
RUN mkdir -p /usr/share/jenkins/ref/casc_configs

# Copy JCasC configuration to ref directory (will be copied to jenkins_home on startup)
COPY jenkins.yaml /usr/share/jenkins/ref/casc_configs/jenkins.yaml

# Disable setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Set JCasC configuration path
ENV CASC_JENKINS_CONFIG="/var/jenkins_home/casc_configs"

# Switch back to jenkins user
USER jenkins

# Expose Jenkins port and JNLP port
EXPOSE 8080 50000

