#!/bin/bash
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
