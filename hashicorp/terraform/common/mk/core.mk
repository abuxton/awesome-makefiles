# https://github.com/krisnova/Makefile/blob/main/Makefile

-include .env
REPO_TOP=$(shell git rev-parse --show-toplevel)
CORE=${REPO_TOP}/common/mk/core.mk
BIN_DIR=${REPO_TOP}/common/bin

all: help

login: ## login to terraform application service
	terraform login

plan: ## terraform init
	terraform init
	terraform plan

module: ## generate a base terraform module `path="."` is the default arg.
	path="."
	mkdir -p ${path}
	touch ${path}/main.tf
	touch ${path}/variables.tf
	touch ${path}/outputs.tf
	touch ${path}/terraform.tf
	touch ${path}/backend.tf
	$(MAKE) backend path=${path}
	touch ${path}/README.md
	cp ${REPO_TOP}/.gitignore ${path}/.gitignore

backend: ## generate a backend.tf file `path="."` is the default arg.
	path="."
	${BIN_DIR}/mk_backend > ${path}/backend.tf


apply: ## terraform apply
	terraform init
	terraform plan
	terraform apply

yolo: ## run terraform apply with yolo flag
	terraform init
	terraform apply -auto-approve

destroy: ## terraform destroy
	terraform apply -destroy

smoketest: ## run terraform tests
	terraform init
	terraform fmt -check -diff
	terraform validate

docs: ## populate README.md with terraform-docs
# requires https://terraform-docs.io/
	path="."
	terraform-docs markdown -c ${REPO_TOP}/.terraform-docs.yml table --output-file README.md ${path}

terraform-override: ## override provided file
	cp ./$(file) $(basename $(file))_override.tf

.PHONY: help
help:  ## Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(CORE)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'
