resource "aws_launch_template" "jenkins_agent_template" {
  name_prefix   = "jenkins-agent"
  image_id      = "ami-04a5bacc58328233d"  # Your Ubuntu AMI
  instance_type = var.instance_type
  key_name      = var.key_name  

  user_data = base64encode(file("install-build-tools.sh"))

  iam_instance_profile {
    name = data.aws_iam_instance_profile.jenkins_profile_existing.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Jenkins-Agent"
    }
  }
}
