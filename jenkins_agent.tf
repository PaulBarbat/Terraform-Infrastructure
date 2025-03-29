# jenkins_agent.tf
resource "aws_launch_template" "jenkins_agent_template" {
  name_prefix   = "jenkins-agent"
  image_id      = "ami-04a5bacc58328233d"  # Ubuntu AMI for eu-central-1
  instance_type = var.instance_type

  key_name = var.key_name  # Your EC2 key pair name

  user_data = base64encode(file("install-build-tools.sh"))

  iam_instance_profile {
    name = data.aws_iam_instance_profile.jenkins_profile_existing.name  # Reference the instance profile
  }

  tags = {
    Name = "Jenkins-Agent"
  }
}

resource "aws_autoscaling_group" "jenkins_agent_asg" {
  desired_capacity = 0  # No agents running when idle
  min_size         = 0  # Start with 0 instances
  max_size         = 1  # Only one agent running at a time

  launch_template {
    id      = aws_launch_template.jenkins_agent_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = ["subnet-03768799a4e986f20"]  # Provide your VPC subnet ID

  # Add any additional configuration such as health check grace period, termination policies, etc.
}
