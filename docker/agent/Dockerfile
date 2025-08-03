FROM --platform=linux/amd64 jenkins/inbound-agent:alpine-jdk17

USER root

# Install necessary tools for CI/CD pipelines
RUN apk --no-cache add \
    git \
    curl \
    zip \
    unzip \
    python3 \
    py3-pip \
    docker \
    jq \
    && pip3 install --upgrade awscli --break-system-packages

# Create workspace directory with proper permissions
RUN mkdir -p /home/jenkins/workspace && \
    chown -R jenkins:jenkins /home/jenkins

# Switch back to jenkins user
USER jenkins

ENTRYPOINT ["/usr/local/bin/jenkins-agent"]

