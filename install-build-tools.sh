#!/bin/bash
# Update system and install required tools
sudo apt update -y
sudo apt install -y openjdk-11-jdk cmake ninja-build git awscli

# Configure Jenkins agent directory
mkdir -p /home/ubuntu/jenkins-agent
cd /home/ubuntu/jenkins-agent

# Fetch Jenkins agent secret dynamically
JENKINS_MASTER="http://63.176.232.211/:8080"
JENKINS_NODE_NAME="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
SECRET=$(curl -s -u "admin:11ceadb4c23b90025ef84b07b4e91bb8a2" "$JENKINS_MASTER/computer/$JENKINS_NODE_NAME/slave-agent.jnlp" | grep -oP '(?<=<secret>).*?(?=</secret>)')

# Download Jenkins agent jar file
wget $JENKINS_MASTER/jnlpJars/agent.jar

# Run Jenkins agent
java -jar agent.jar -jnlpUrl $JENKINS_MASTER/computer/$JENKINS_NODE_NAME/slave-agent.jnlp -secret $SECRET -workDir "/home/ubuntu/jenkins-agent"

# Keep the agent alive
while true; do sleep 1000; done
