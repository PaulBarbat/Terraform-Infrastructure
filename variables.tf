# variables.tf
variable "security_group_name" {
  description = "The name of the security group for Jenkins"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where Jenkins resources will be created"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  default     = "t3.micro"
}

variable "ebs_volume_id" {
  description = "The ID of the existing EBS volume to attach to the Jenkins master"
  type        = string
}

variable "key_name" {
  description = "The EC2 key pair name"
  type        = string
}
