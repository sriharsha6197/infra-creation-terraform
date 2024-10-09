dev:
	terraform init --backend-config=dev-env/state.tfvars
	terraform plan --var-file=dev-env/input.tfvars
	terraform apply --auto-approve --var-file=dev-env/input.tfvars
dev-destroy:
	terraform init --backend-config=dev-env/state.tfvars
	terraform destroy --auto-approve --var-file=dev-env/input.tfvars
prod:
	terraform init --backend-config=prod-env/state.tfvars
	terraform apply --auto-approve --var-file=prod-env/input.tfvars
prod-destroy:
	terraform init --backend-config=prod-env/state.tfvars
	terraform destroy --auto-approve --var-file=prod-env/input.tfvars