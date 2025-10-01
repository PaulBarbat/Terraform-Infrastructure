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

set -e  # Exit immediately if a command exits with a non-zero status

# Update system packages
apt update -y

# Ensure required dependencies are installed
apt install -y openjdk-17-jdk awscli

# Define the EBS volume and mount point
EBS_DEVICE="/dev/nvme1n1"
MOUNT_POINT="/mnt/jenkins_home"

# Ensure the mount point exists
mkdir -p $MOUNT_POINT

# Check if the device is already mounted
if ! mount | grep -q $MOUNT_POINT; then
    # Mount the EBS volume
    mount $EBS_DEVICE $MOUNT_POINT
    
    # Ensure the mount persists across reboots
    echo "$EBS_DEVICE $MOUNT_POINT ext4 defaults,nofail 0 2" >> /etc/fstab
fi

# Set correct ownership and permissions
chown -R jenkins:jenkins $MOUNT_POINT
chmod -R 775 $MOUNT_POINT

# Restart Jenkins to apply the correct JENKINS_HOME
systemctl restart jenkins

#TODO
    #Make EBS mount idempotent and detect if the device is formatted, if not, mkfs.ext4
    #Use set -euo pipefail and log actions
    #Use terraform to create and attach EBS
    #Only append mount entry if not already there
    
