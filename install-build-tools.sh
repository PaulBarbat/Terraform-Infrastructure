#!/bin/bash
# Update system and install required tools
sudo apt update -y
sudo apt install -y openjdk-11-jdk cmake ninja-build git awscli

# Configure Jenkins agent directory
mkdir -p /home/ubuntu/jenkins-agent
cd /home/ubuntu/jenkins-agent

# Download Jenkins agent jar file
wget http://<JENKINS_MASTER_IP>:8080/jnlpJars/agent.jar

# Run Jenkins agent and connect to master
java -jar agent.jar \
  -jnlpUrl http://<JENKINS_MASTER_IP>:8080/computer/jenkins-agent/slave-agent.jnlp \
  -secret <AGENT_SECRET> \
  -workDir "/home/ubuntu/jenkins-agent"

# Keep the agent alive (this helps avoid instance termination issues)
while true; do sleep 1000; done