up:
	cd infra && terraform init
	cd infra && terraform apply --auto-approve

output:
	cd infra && terraform output

plan:
	cd infra && terraform plan

ans:
	cd ansible && chmod +x run_ansible.sh && ./run_ansible.sh

ec2:
	ssh -i ~/.ssh ec2-user@${public_ip_of_private_server}
down:
	cd infra && terraform destroy --auto-approve
