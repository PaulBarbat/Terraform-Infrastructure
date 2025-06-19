# Terraform Infrastructure for Jenkins

## Overview
This repository contains Terraform configurations for provisioning infrastructure on AWS. The main goal is to set up a **Jenkins master node** along with an **auto-scaling group** for Jenkins agents. It also provisions necessary resources like security groups, IAM roles, and networking components.

## Repository Structure
```
├── main.tf                  # Main Terraform configuration file
├── variables.tf             # Input variables for Terraform
├── outputs.tf               # Output variables for Terraform
├── providers.tf             # Provider configurations (AWS, etc.)
├── security.tf              # Security group definitions
├── jenkins-master.tf        # Jenkins master instance setup
├── jenkins-agents.tf        # Auto-scaling group for Jenkins agents
├── userdata-master.sh       # User data script for Jenkins master
├── userdata-agent.sh        # User data script for Jenkins agents
├── README.md                # This file
```

## Prerequisites
Before using this repository, ensure you have the following tools installed:

- **Terraform** (>= 1.0.0) - [Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
or using choco, run inside powershell with admin rights "choco install terraform" then run "terraform --version" to make sure it is installed
- **AWS CLI** (configured with appropriate credentials)
- **SSH Key Pair** for accessing EC2 instances

## Usage
### 1. Clone the Repository
```sh
git clone https://github.com/PaulBarbat/Terraform-Infrastructure.git
cd your-repo
```

### 2. Initialize Terraform
```sh
terraform init
```

### 3. Plan the Deployment
```sh
terraform plan
```
This command will show the changes Terraform will apply.

### 4. Apply the Configuration
```sh
terraform apply -auto-approve
```
Terraform will create all resources defined in the `.tf` files.

### 5. Destroy the Infrastructure (if needed)
```sh
terraform destroy -auto-approve
```

## Debugging and Troubleshooting
Here are some common issues and their debugging steps:

### Jenkins Master Not Retaining Data
- Check if the **EBS volume is mounted correctly**
  ```sh
  lsblk
  df -h
  ```
- If not mounted, manually mount it:
  ```sh
  sudo mount /dev/nvme1n1 /mnt/jenkins_home
  ```
- Verify **JENKINS_HOME**
  ```sh
  sudo systemctl show jenkins | grep Environment
  ```

### SSH Connection Issues
- Ensure your **security group allows inbound SSH traffic (port 22)**.
- Check your **Elastic IP configuration**.
- If SSH key issues arise:
  ```sh
  ssh-keygen -R <jenkins-master-ip>
  ```

### Jenkins Service Not Starting
- Check the **systemd service logs**:
  ```sh
  sudo systemctl status jenkins
  sudo journalctl -u jenkins --no-pager
  ```
- If there is an invalid unit file setting:
  ```sh
  sudo systemctl daemon-reexec
  sudo systemctl daemon-reload
  sudo systemctl restart jenkins
  ```

## Future Improvements
- Automate SSL configuration for Jenkins.
- Integrate Terraform remote state storage.
- Implement Terraform modules for better organization.

---

Setup:

1. Using choco, run inside powershell with admin rights "choco install terraform" then run "terraform --version" to make sure it is installed
2. inside terraform repo run "terraform init"
3. terraform apply -auto-approve

terraform apply -target=aws_security_group.jenkins_sg


Testing:
sudo systemctl status jenkins
sudo netstat -tulnp | grep 8080
sudo systemctl restart jenkins

Jenkins with debugging:
sudo systemctl stop jenkins
sudo jenkins --httpListenAddress=0.0.0.0 --httpPort=8080

Debugging jenkins if the EBS module dismounts
sudo systemctl status jenkins
  100  sudo systemctl start jenkins
  101  journalctl -xe
  102  lsblk
  103  cat /etc/fstab
  104  sudo nano /etc/fstab
  -Comment the module which is not found in the lsblk list
  105  sudo mount -a
  106  sudo systemctl start jenkins
  108  sudo systemctl status jenkins

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

ssh-keygen -R 63.176.232.211
ssh -i .\Terraform_key.pem ubuntu@63.176.232.211  #master
ssh -i .\Terraform_key.pem ubuntu@3.79.243.34   #agent