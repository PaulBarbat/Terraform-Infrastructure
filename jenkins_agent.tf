# Jenkins Agent Launch Template
resource "aws_launch_template" "jenkins_agent_template" {
  name_prefix   = "jenkins-agent"           #TODO trailing dash in name prefix
  image_id      = "ami-01f9b4e7cd3e0bbed"   #TODO use data "aws_ami" lookup (owner + filter) to adjust for regional differences
  instance_type = var.instance_type         #TODO validate
  key_name      = var.key_name              #TODO Validate

# Cloud-init or user-data script to run on instance boot for provisioning.
# TODO: Consider baking AMIs with Packer or using configuration management (Ansible) for production instead of long user-data scripts.
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

# References an EBS volume for persistent storage.
# TODO: Ensure the EBS volume lifecycle and availability across AZs match instance placement; consider creating the EBS volume in Terraform rather than referencing an external one.
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

#TODO: Remove public IPs for agents, place them in private subnets with NAT
#TODO: Restrict security group rules to master↔agent only, remove wide-open ingress
# References an EBS volume for persistent storage.
# TODO: Ensure the EBS volume lifecycle and availability across AZs match instance placement; consider creating the EBS volume in Terraform rather than referencing an external one.
#TODO: Enable EBS encryption and optionally use a KMS key
#TODO: Stop using SSH key pairs, switch to SSM Session Manager
#TODO: Manage IAM instance profile in Terraform and apply least privilege
#TODO: Remove secrets from install-build-tools.sh, fetch from SSM/Secrets Manager
#TODO: Rotate any credentials that may have been committed to repo
#TODO: Replace hard-coded AMI ID with data "aws_ami" filter (latest Ubuntu/Amazon Linux)
#TODO: Replace hard-coded subnet ID with var.private_subnet_ids across multiple AZs
#TODO: Replace hard-coded ASG sizes with variables (min, max, desired)
#TODO: Decide scaling model: Jenkins-managed vs AWS AutoScaling policies
#TODO: If AWS scaling, add target-tracking policy (CPU or queue length)
#TODO: Add lifecycle block create_before_destroy = true for safer updates
#TODO: Tag EBS volumes in addition to instances
#TODO: Tune gp3 volume size/IOPS/throughput for build performance
#TODO: Add common_tags (Env, Owner, CostCenter) to all resources
#TODO: Consider Spot Instances for build agents to save cost
#TODO: Bake AMIs with Packer for faster agent spin-up
#TODO: Add CloudWatch metrics/alarms for ASG health and agent failures
#TODO: Secure Terraform state with S3 backend + DynamoDB locking
#TODO: Add terraform fmt/validate/tflint/tfsec checks to CI/CD pipeline
