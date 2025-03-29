#!/bin/bash
apt update -y
apt install -y openjdk-17-jdk

# Mount the specific EBS volume
mkdir -p /mnt/jenkins_home
mount /dev/xvdf /mnt/jenkins_home
echo "/dev/xvdf /mnt/jenkins_home ext4 defaults,nofail 0 2" >> /etc/fstab

# Set Jenkins Home
export JENKINS_HOME=/mnt/jenkins_home
systemctl restart jenkins
