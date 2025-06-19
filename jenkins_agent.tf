# Jenkins Agent Launch Template
resource "aws_launch_template" "jenkins_agent_template" {
  name_prefix   = "jenkins-agent"
  image_id      = "ami-01f9b4e7cd3e0bbed"
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(file("install-build-tools.sh"))

  iam_instance_profile {
    name = data.aws_iam_instance_profile.jenkins_profile_existing.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.jenkins_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 20  # Increase this value as needed
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Jenkins-Agent"
    }
  }
}


# Jenkins Agent Auto Scaling Group
resource "aws_autoscaling_group" "jenkins_agent_asg" {
  name              = "jenkins-agent-asg"
  min_size         = 0  # No agents running when idle
  max_size         = 1  # Maximum of 1 agent at a time
  desired_capacity  = 0  # Let Jenkins scale agents as needed

  vpc_zone_identifier = ["subnet-03768799a4e986f20"]  # Replace with your actual subnet ID

  launch_template {
    id      = aws_launch_template.jenkins_agent_template.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300  # Wait 5 minutes before considering an instance unhealthy

  tag {
    key                 = "Name"
    value               = "Jenkins-Agent"
    propagate_at_launch = true
  }
}