# Makefile for Terraform scripts

# Terraform working directory
TF_DIR := terraform/base

# Terraform variables file (relative to TF_DIR)
TFVARS ?= ../../terraform.tfvars

setup: # Setup's local machine
	brew install terraform
	brew install tflint
	brew install jq
	brew install ansible
	git submodule update --init --recursive
.PHONY: setup

fmt: # Format Terraform files
	terraform fmt -recursive
.PHONY: fmt

lint: # Lint Terraform files
	tflint
.PHONY: lint

init: # Initialize Terraform with B2 backend
	terraform -chdir=$(TF_DIR) init -upgrade \
		-backend-config="access_key=${BACK_BLAZE_KEY_ID}" \
		-backend-config="secret_key=${BACK_BLAZE_APPLICATION_KEY}"
.PHONY: init

init-vendor: # Initialize Git submodules (WebKit roles)
	git submodule update --init --recursive
	@echo "WebKit submodule initialized successfully"
.PHONY: init-vendor

update-roles: # Update WebKit Ansible roles to latest
	git submodule update --remote vendor/webkit
	@echo "WebKit roles updated to latest version"
.PHONY: update-roles

plan: # Run Terraform plan
	terraform -chdir=$(TF_DIR) plan -var-file=$(TFVARS)
.PHONY: plan

apply: # Apply Terraform changes
	terraform -chdir=$(TF_DIR) apply -var-file=$(TFVARS)
.PHONY: apply

destroy: # Destroy Terraform infrastructure
	terraform -chdir=$(TF_DIR) destroy -var-file=$(TFVARS)
.PHONY: destroy

output: # Show Terraform outputs
	terraform -chdir=$(TF_DIR) output
.PHONY: output

ssh-key: # Save SSH private key to file
	terraform -chdir=$(TF_DIR) output -raw ssh_private_key > uptime-kuma-key.pem
	chmod 600 uptime-kuma-key.pem
	@echo "SSH key saved to uptime-kuma-key.pem"
.PHONY: ssh-key

deploy-uptime: init-vendor # Deploy or update Uptime Kuma using Ansible
	@echo "Deploying Uptime Kuma..."
	@if [ ! -f ansible/inventory-uptime-kuma.ini ]; then \
		echo "Error: Ansible inventory file not found. Run 'make apply' first to generate it."; \
		exit 1; \
	fi
	cd ansible && ansible-playbook -i inventory-uptime-kuma.ini playbooks/uptime-kuma.yaml
.PHONY: deploy-uptime

todo: # Show to-do items per file
	$(Q) grep \
		--exclude=Makefile.util \
		--exclude-dir=vendor \
		--exclude-dir=.vercel \
		--exclude-dir=.gen \
		--exclude-dir=.idea \
		--exclude-dir=public \
		--exclude-dir=node_modules \
		--exclude-dir=archetypes \
		--exclude-dir=.git \
		--text \
		--color \
		-nRo \
		-E '\S*[^\.]TODO.*' \
		.
.PHONY: todo

help: # Display this help
	$(Q) awk 'BEGIN {FS = ":.*#"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?#/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
.PHONY: help
