up:
	cd infra && terraform init
	cd infra &&	terraform apply --auto-approve

kube-up:
	kops create cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) --name=rmit.k8s.local --zones=us-east-1a --master-size=t2.medium --yes

kube-down:
	kops delete cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name) rmit.k8s.local --yes

down:
	cd infra && terraform destroy --auto-approve

kube-validate:
	kops validate cluster --state=s3://$(shell cd infra && terraform output kops_state_bucket_name)
