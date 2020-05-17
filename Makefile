printCreds:
	cd ~/.aws && sed -n 2,4p credentials

start:
	make start1
	make start2
	make start3
	make ans

start1: # backendUp
	cd infra/backend && terraform init
	cd infra/backend && terraform apply --auto-approve

start2: # init
	cd infra && terraform init --backend-config="bucket=rmit-tfstate-${shell cat ./infra/backend/randomstring.txt}" --backend-config="dynamodb_table=RMIT-locktable-${shell cat ./infra/backend/randomstring.txt}"

start3: # up
	cd infra && terraform apply --auto-approve

stop:
	make stop1
	make stop2
	make stop3

stop1: # down
	cd infra && terraform destroy --auto-approve

stop2: # backendDown
	cd infra/backend && terraform destroy --auto-approve

stop3: # Destroy the .terraform/terraform.tstate, otherwise a new s3bucket/dynamodb_table can't be registered: https://stackoverflow.com/questions/50844085/error-inspecting-states-in-the-s3-backend-nosuchbucket-the-specified-bucket
	cd infra/.terraform && terraform destroy --auto-approve
	cd infra/.terraform && rm terraform.tfstate && terraform init

output:
	cd infra && terraform output

plan:
	cd infra && terraform plan

ans:
	cd ansible && chmod +x run_ansible.sh && ./run_ansible.sh

ec2:
	ssh -i ~/.ssh ec2-user@${shell cat ./infra/makefileIP.txt}
