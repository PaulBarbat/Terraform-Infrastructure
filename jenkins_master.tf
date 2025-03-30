# jenkins_master.tf
resource "aws_instance" "jenkins_master" {
  ami                   = "ami-0ae607bdbb9253cad"  # Ubuntu AMI for your region
  instance_type         = var.instance_type
  key_name              = var.key_name           # Replace with your actual key pair name
  security_groups       = [aws_security_group.jenkins_sg.name]  # Reference security group from security_group.tf
  iam_instance_profile  = data.aws_iam_instance_profile.jenkins_profile_existing.name  # Reference IAM instance profile from instance_profile.tf

  user_data = base64encode(file("install-jenkins.sh"))

  tags = {
    Name = "Jenkins-Master"
  }
}

# Attach existing EBS volume to the Jenkins master instance
resource "aws_volume_attachment" "jenkins_master_attachment" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.jenkins_master.id
  volume_id   = var.ebs_volume_id  # Reference EBS volume ID variable
}

# Manually created Elastic IP (you provide this manually through the variable)
resource "aws_eip_association" "jenkins_master_eip_association" {
  instance_id   = aws_instance.jenkins_master.id
  allocation_id = var.elastic_ip_allocation_id  # Use the allocation ID of the manually created EIP
}