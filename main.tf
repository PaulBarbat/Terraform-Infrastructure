provider "aws" {
  region = "eu-central-1"  # Frankfurt
}

# This resource is only needed if you haven't imported the security group yet.
# If you have already imported, you do not need this resource.
# This is for illustration purposes.
resource "aws_security_group" "jenkins_sg" {
  # No `id` field here. Instead, after the import, Terraform will recognize this existing resource.
  name        = "jenkins-security-group"
  description = "Security group for Jenkins EC2 instances"
  vpc_id      = "vpc-0144ffccd0fe563c0"  # Your VPC ID (ensure it's correct)

  # Example inbound and outbound rules (adjust according to your requirements)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data source to reference the existing IAM role
data "aws_iam_role" "jenkins_role" {
  name = "jenkins-ec2-role-terraform"  # The name of the IAM role you created manually
}

# Jenkins instance profile - This links the IAM role to the EC2 instance
resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-instance-profile"
  role = data.aws_iam_role.jenkins_role.name  # Use the role from the data source
}

# Jenkins agent AWS launch template
resource "aws_launch_template" "jenkins_agent_template" {
  name_prefix   = "jenkins-agent"
  image_id      = "ami-04a5bacc58328233d"  # Ubuntu AMI for eu-central-1 (make sure to use the right AMI for your region)
  instance_type = "t3.micro"  # Free-tier eligible instance

  key_name = "Terraform key"  # Your EC2 key pair name

  user_data = base64encode(file("install-build-tools.sh"))

  iam_instance_profile {
    name = aws_iam_instance_profile.jenkins_profile.name  # Reference the instance profile
  }

  tags = {
    Name = "Jenkins-Agent"
  }
}

# Jenkins master instance
resource "aws_instance" "jenkins_master" {
  ami                   = "ami-04a5bacc58328233d"  # Ubuntu AMI for your region
  instance_type         = "t3.micro"
  key_name              = "Terraform key"           # Replace with your actual key pair name
  security_groups       = [aws_security_group.jenkins_sg.name]  # Attach the imported security group
  iam_instance_profile  = aws_iam_instance_profile.jenkins_profile.name  # Attach the IAM instance profile

  user_data = base64encode(file("install-jenkins.sh"))

  tags = {
    Name = "Jenkins-Master"
  }
}

# Jenkins worker (AutoScaling Group)
resource "aws_autoscaling_group" "jenkins_agent_asg" {
  desired_capacity = 0  # No agents running when idle
  min_size         = 0  # Start with 0 instances
  max_size         = 1  # Only one agent running at a time

  launch_template {
    id      = aws_launch_template.jenkins_agent_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = ["subnet-03768799a4e986f20"]  # Provide your VPC subnet ID here

  # Add any additional configuration such as health check grace period, termination policies, etc.
}

output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}
