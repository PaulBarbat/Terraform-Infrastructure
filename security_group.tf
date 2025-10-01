# security_group.tf
resource "aws_security_group" "jenkins_sg" {
  name        = var.security_group_name # This will reference the variable or ID you provide
  description = "Security group for Jenkins EC2 instances"
  vpc_id      = var.vpc_id # Reference to the VPC ID variable

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the world for Jenkins web interface
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the world for HTTPS
  }

  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to the world for Jenkins agent communication
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Allow all traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}

#TODO
#Manage rules more strictly
#Use SSM and remove SSH from security groups 
#Do not expose 50000
#Put master and agent in same VPC/Private subnet
#Use aws_security_group_rule resource to add and remove rules 