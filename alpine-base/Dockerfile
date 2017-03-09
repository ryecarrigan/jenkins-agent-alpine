# Base image for Jenkins agents running on OpenJDK Alpine
FROM openjdk:8-alpine

# Set up variables
ENV AGENT_JAR="/usr/share/jenkins/jenkins-agent.jar" REMOTING_VER=3.7

# Execute all commands in one go
RUN \
    # Install basic tools
    apk add --no-cache \
        bash \
        curl \
        git \
        openssh \

    # Acquire the Jenkins remoting JAR and place it on the target
    && curl --create-dirs -sSLo ${AGENT_JAR} \
        https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${REMOTING_VER}/remoting-${REMOTING_VER}.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 ${AGENT_JAR} \

    # Create a Jenkins user
    && adduser -S jenkins

# Add the agent startup script and set it as the entrypoint
COPY jenkins-agent.sh /usr/local/bin/jenkins-agent
ENTRYPOINT ["jenkins-agent"]

# Finally, let the Jenkins user take over
USER jenkins
WORKDIR /home/jenkins
