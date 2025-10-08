# variables.tf
# used to name security group for jenkins
variable "security_group_name" {
  description = "The name of the security group for Jenkins"
  type        = string
}

# The ID of the VPC in which all resources will be created
variable "vpc_id" {
  description = "The VPC ID where Jenkins resources will be created"
  type        = string
}

# Default value for the instance to be created
variable "instance_type" {
  description = "Instance type for the EC2 instance"
  default     = "t3.micro"
}

# Refers to an existing EBS volume to be mounted to the jenkins master
variable "ebs_volume_id" {
  description = "The ID of the existing EBS volume to attach to the Jenkins master"
  type        = string
}

# Name of the key pair used in AWS ECT for SSH access
# This key has to exist in AWS and locally as a .pem file
variable "key_name" {
  description = "The EC2 key pair name"
  type        = string
}

#An Elastic IP allocation ID to assign a static IP to Jenkins Master
variable "elastic_ip_allocation_id" {
  description = "The Elastic IP allocation ID to attach to the Jenkins Master (leave empty to skip)"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1" # preserve current behavior
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDRs allowed to SSH to Jenkins. Override in terraform.tfvars for production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "master_ami" {
  description = "AMI for Jenkins master (default = current AMI)"
  type        = string
  default     = "ami-0ae607bdbb9253cad"
}

variable "agent_ami" {
  description = "AMI for Jenkins agents (default = current AMI)"
  type        = string
  default     = "ami-01f9b4e7cd3e0bbed"
}

#TODO Variable validation
#TODO Make variables optional where we can 
#TODO Group by purpose