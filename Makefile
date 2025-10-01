fmt:
	terraform fmt -recursive

init:
	terraform init

validate:
	terraform validate

plan:
	terraform plan -out=tfplan

apply:
	terraform apply tfplan

destroy:
	terraform destroy -auto-approve
