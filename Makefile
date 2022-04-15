.ONESHELL:

## load common variables and anything environment specific that overrides
export ENV_GLOBAL_PATH 	 ?= $(CURDIR)/config/common/.env
export ENV_OVERRIDE_PATH ?= $(CURDIR)/config/${ENVIRONMENT}/.env

-include $(ENV_GLOBAL_PATH)
-include $(ENV_OVERRIDE_PATH)

## export all vars
export

# REQUIRED_TOOLS_LIST := docker git make jq helm yq
# #jq kubectl helm packer terraform ansible helmfile sops
# CHECK_TOOLS := $(foreach tool,$(REQUIRED_TOOLS_LIST), $(if $(shell which $(tool)),some string,$(error "No $(tool) in PATH")))


####
## Configure Calm DSL and Docker Container
####

docker-build docker-run init-dsl-config: print-vars

.PHONY: docker-build
docker-build: ## Rebuild Calm DSL Image with latest version in Docker Hub
	# this will clean existing docker caml-dsl images and subsequently build ntnx/calm-dsl latest with dev-utils (i.e., gnu-make,git,pandoc).  Lastly, it will run interactive container with bind mounted with working dir
	@docker rmi -f calm-dsl-utils:latest
	@docker rmi -f ntnx/calm-dsl:latest
	@docker build -t calm-dsl-utils .

.PHONY: docker-run
docker-run: ## Launch into interactively Calm DSL Docker container
	# validate whether or not you have image built locally, ortherwise, build it
	[ -n "$$(docker image ls calm-dsl-utils -q)" ] || make docker-build
	# this will just exec you into the interactive container
	@docker run --rm -it \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v `pwd`:/dsl-workspace \
		-v `pwd`/.local/${KALM_ENVIRONMENT}:/root/.calm/.local \
		-w '/dsl-workspace' \
		calm-dsl-utils /bin/sh -c "make print-vars KALM_ENVIRONMENT=${KALM_ENVIRONMENT} && bash"

.PHONY: init-dsl-config
init-dsl-config: ## Initialize calm dsl configuration with environment specific configs
	# validate that you're inside container.  If you were just put into container, you may need to re-run last command
	[ -f /.dockerenv ] || make docker-run KALM_ENVIRONMENT=${KALM_ENVIRONMENT};
	[ ! -f /.dockerenv ] || calm init dsl ${DSL_INIT_PARAMS} --project "${CALM_PROJECT}"; \
		calm get projects -n "${CALM_PROJECT}"; \
		calm get server status

##############
## Helpers

.PHONY: print-vars
print-vars: ### Print environment variables. i.e., make print-vars ENVIRONMENT={environment_folder_name}
	@for envvar in $$(cat $(ENV_GLOBAL_PATH) $(ENV_OVERRIDE_PATH) | cut -d= -f1 | sort -usf | xargs -n 1); do `echo env` | grep -vi "pass" | grep "$$envvar=" 2>/dev/null; done; 2>/dev/null

.PHONY: print-secrets
print-secrets: ### Print variables including secrets. i.e., make print-secrets ENVIRONMENT={environment_folder_name} | egrep -i "user|pass|key"
	@for envvar in $$(cat $(ENV_GLOBAL_PATH) $(ENV_OVERRIDE_PATH) | cut -d= -f1 | sort -usf | xargs -n 1); do `echo env` | grep "$$envvar=" 2>/dev/null; done; 2>/dev/null

.DEFAULT_GOAL := help
.PHONY: help
help: ### Show this help
	@egrep -h '\s###\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?### "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
