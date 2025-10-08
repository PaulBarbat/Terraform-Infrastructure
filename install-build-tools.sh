#!/usr/bin/env bash
set -euo pipefail

# Region fallback (pick up environment or use metadata)
REGION="${REGION:-eu-central-1}"

# Prefer SSM Parameter; fallback to environment or legacy value
# NOTE: set /jenkins/agent-secret in SSM Parameter Store (SecureString) and assign IAM permission to EC2 role.
SECRET=""
if command -v aws >/dev/null 2>&1; then
  SECRET=$(aws ssm get-parameter --name "/jenkins/agent-secret" --with-decryption --region "${REGION}" --query "Parameter.Value" --output text 2>/dev/null || true)
fi

# Fallback to environment variable if provided
if [ -z "${SECRET:-}" ] && [ -n "${JENKINS_AGENT_SECRET:-}" ]; then
  SECRET="${JENKINS_AGENT_SECRET}"
fi

# FINAL fallback: placeholder legacy (keeps behavior if you don't configure SSM yet).
if [ -z "${SECRET:-}" ]; then
  SECRET="<FALLBACK_LEGACY_SECRET_PLACEHOLDER>"
fi

# Ensure agent directory exists and set up systemd unit instead of while-true loop (example):
AGENT_DIR="/home/ubuntu/jenkins-agent"
mkdir -p "$AGENT_DIR"

# download agent jar idempotently
if [ ! -f "$AGENT_DIR/agent.jar" ]; then
  wget -O "$AGENT_DIR/agent.jar" "${JENKINS_MASTER%/}/jnlpJars/agent.jar"
fi

# create systemd service
cat >/etc/systemd/system/jenkins-agent.service <<EOF
[Unit]
Description=Jenkins Agent
After=network-online.target

[Service]
Type=simple
User=ubuntu
ExecStart=/usr/bin/java -jar $AGENT_DIR/agent.jar -jnlpUrl ${JENKINS_MASTER}/computer/${JENKINS_NODE_NAME}/jenkins-agent.jnlp -secret ${SECRET} -workDir ${AGENT_DIR}
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now jenkins-agent.service

# Update system and install required tools
sudo apt update -y
sudo apt install -y openjdk-11-jdk cmake ninja-build git awscli libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev g++-mingw-w64 pkg-config

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

#TODO 
    #Remove secrets
    #Use AWS SSM Parameter store or Secrets Manager to provide secrets at runtime
    #Use systemd to run the agent as a managed service
    #Use more secure IAM roles
    #Use private networks
    #Idempotence & safety: add set -euo pipefail, check whether agent.jar already downloaded, and use retries/backoff for network calls.