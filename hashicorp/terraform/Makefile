# https://github.com/krisnova/Makefile/blob/main/Makefile

-include .env

all: help

login: ## login to terraform application service $hotname=app.terraform.io is default
	hostname="app.terraform.io"
	terraform login $hostname

module: ## generate a base terraform module `path="."` is the default arg.
	path="."
	touch ${path}/main.tf
	touch ${path}/variables.tf
	touch ${path}/outputs.tf
	touch ${path}/terraform.tf
	touch ${path}/backend.tf
	touch ${path}/README.md
	touch ${path}/.gitignore

plan: ## terraform init & plan
	terraform init
        terraform plan

apply: ## terraform apply
	terraform init
	terraform apply

destroy: ## terraform destroy
	terraform apply -destroy

docs: ## populate README.md with terraform-docs
# requires https://terraform-docs.io/
	terraform-docs markdown table --hide-empty --sort-by=required --lockfile=false --output-file README.md .

vars: ## populate tfvars with terraform-docs output
# requires https://terraform-docs.io/
	terraform-docs tfvars hcl .

validate: ## terraform fmt & validate
# add lint at somepoint
	terraform init
	terraform fmt
	terraform validate

terraform-override: ## override provided ./filename.tf
	cp ./$(file) $(basename $(file))_override.tf

.PHONY: help
help:  ## Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'
