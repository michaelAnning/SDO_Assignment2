up:
	cd infra && terraform init
	cd infra &&	terraform apply --auto-approve

down:
	cd infra && terraform destroy --auto-approve
