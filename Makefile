.PHONY: help bootstrap plan apply deploy destroy validate lint test build-image

ENV ?= dev
AWS_REGION ?= us-east-1
TF_DIR := infrastructure/terraform/environments/$(ENV)
BOOTSTRAP_DIR := infrastructure/terraform/bootstrap

help:
	@echo "CloudForge — Infrastructure Platform"
	@echo ""
	@echo "Usage:"
	@echo "  make bootstrap          Bootstrap remote Terraform state (once per AWS account)"
	@echo "  make plan ENV=dev       Terraform plan for environment"
	@echo "  make apply ENV=dev      Terraform apply for environment"
	@echo "  make deploy ENV=dev     Full deploy (infra + app)"
	@echo "  make destroy ENV=dev    Destroy environment resources"
	@echo "  make validate           Validate all Terraform modules"
	@echo "  make lint               Lint Python application code"
	@echo "  make test               Run application tests"
	@echo "  make build-image        Build Docker image locally"

bootstrap:
	@bash scripts/bootstrap.sh

plan:
	@cd $(TF_DIR) && terraform init -upgrade && terraform plan

apply:
	@cd $(TF_DIR) && terraform init -upgrade && terraform apply

deploy:
	@bash scripts/deploy.sh $(ENV)

destroy:
	@cd $(TF_DIR) && terraform init -upgrade && terraform destroy

validate:
	@find infrastructure/terraform -name "*.tf" -path "*/modules/*" -o -path "*/environments/*" | xargs -I{} dirname {} | sort -u | while read dir; do \
		echo "Validating $$dir..."; \
		(cd $$dir && terraform init -backend=false -upgrade > /dev/null 2>&1 && terraform validate) || exit 1; \
	done

lint:
	@cd app && ruff check src tests
	@cd app && mypy src

test:
	@cd app && pytest tests/ -v

build-image:
	@docker build -t cloudforge:latest app/
