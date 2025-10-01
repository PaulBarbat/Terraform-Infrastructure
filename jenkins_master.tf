# jenkins_master.tf
# Creates an EC2 Instance for the Jenkins Master
resource "aws_instance" "jenkins_master" {
  #Uses a pre-existing AMI configured manually
  ami                  = var.master_ami                                     # Ubuntu AMI for your region
  instance_type        = var.instance_type                                           #Uses configured instance type
  key_name             = var.key_name                                                # Replace with your actual key pair name
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]                      # Reference security group from security_group.tf
  iam_instance_profile = data.aws_iam_instance_profile.jenkins_profile_existing.name # Reference IAM instance profile from instance_profile.tf

  user_data = base64encode(file("install-jenkins.sh")) #user data script 

  tags = {
    Name = "Jenkins-Master"
  }
}

# Attach existing EBS volume to the Jenkins master instance
resource "aws_volume_attachment" "jenkins_master_attachment" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.jenkins_master.id
  volume_id   = var.ebs_volume_id # Reference EBS volume ID variable
}

# Manually created Elastic IP (you provide this manually through the variable)
resource "aws_eip_association" "jenkins_master_eip_association" {
  count = length(trimspace(var.elastic_ip_allocation_id)) > 0 ? 1 : 0

  instance_id   = aws_instance.jenkins_master.id
  allocation_id = var.elastic_ip_allocation_id
}
#TODO
#Try and build a custom AMI with Packer
#Use vpc_security_group_ids = [aws_security_group.jenkins_sg.id] for security security_groups
#Create EBS using terraform
#Manage EIP via Terraform or create an ALB with an ACM certificate and use DNS 