# instance_profile.tf

# Data source to reference the existing IAM role
data "aws_iam_role" "jenkins_role" {
    # The name of the IAM role you created manually
  name = "jenkins-ec2-role-terraform"  # The name of the IAM role you created manually
}

# Data source to reference the existing IAM instance profile
data "aws_iam_instance_profile" "jenkins_profile_existing" {
      # The name of the existing IAM instance profile
  name = "jenkins-instance-profile"  # The name of the existing IAM instance profile
}
