dev:
	terraform init --backend-config=dev-env/state.tfvars
	terraform plan --var-file=dev-env/input.tfvars
	terraform apply --var-file=dev-env/input.tfvars