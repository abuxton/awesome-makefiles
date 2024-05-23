# https://github.com/krisnova/Makefile/blob/main/Makefile

-include .env

all: help

login: ## login to terraform application service
	terraform login

init: ## terraform init
	terarform init
module: ## generate a base terraform module
	touch ./main.tf
	touch ./variables.tf
	touch ./outputs.tf
	touch ./terraform.tf
	touch ./backend.tf
	touch ./README.md
	touch ./.gitignore
plan: ## terraform plan
	terraform plan
apply: ## terraform apply
	terraform init
	terraform plan
	terraform apply

destroy: ## terraform destroy
	terraform apply -destroy

docs: ## populate README.md with terraform-docs
# requires https://terraform-docs.io/
	terraform-docs markdown table --output-file README.md .

terraform-override: ## override provided file
	cp ./$(file) $(basename $(file))_override.tf

.PHONY: help
help:  ## Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'
