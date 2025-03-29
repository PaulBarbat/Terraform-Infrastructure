# Terraform-Infrastructure
Terraform Infrastructure

Setup:

1. Using choco, run inside powershell with admin rights "choco install terraform" then run "terraform --version" to make sure it is installed
2. inside terraform repo run "terraform init"
3. terraform apply -auto-approve

terraform apply -target=aws_security_group.jenkins_sg


Testing:
sudo systemctl status jenkins
sudo netstat -tulnp | grep 8080
sudo systemctl restart jenkins

Jenkins with debugging:
sudo systemctl stop jenkins
sudo jenkins --httpListenAddress=0.0.0.0 --httpPort=8080

sudo cat /var/lib/jenkins/secrets/initialAdminPassword