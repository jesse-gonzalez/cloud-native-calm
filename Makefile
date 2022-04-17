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
		-v `pwd`/.local/${ENVIRONMENT}:/root/.calm/.local \
		-w '/dsl-workspace' \
		calm-dsl-utils /bin/sh -c "make init-dsl-config ENVIRONMENT=${ENVIRONMENT} && /bin/zsh"

.PHONY: init-dsl-config
init-dsl-config: print-vars ## Initialize calm dsl configuration with environment specific configs
	# validate that you're inside container.  If you were just put into container, you may need to re-run last command
	[ -f /.dockerenv ] || make docker-run ENVIRONMENT=${ENVIRONMENT};
	[ ! -f /.dockerenv ] || calm init dsl ${DSL_INIT_PARAMS} --project "${CALM_PROJECT}";

## Common BP command based on DSL_BP path passed in. To Run, make create-dsl-bps <dsl_bp_folder_name>

create-dsl-bps launch-dsl-bps delete-dsl-bps delete-dsl-apps: init-dsl-config

create-dsl-bps: ### Create bp with corresponding git feature branch and short sha code. i.e., make create-dsl-bps DSL_BP=karbon_admin_ws
	@make -C dsl/${DSL_BP} create-bp

launch-dsl-bps: ### Launch Blueprint that matches your git feature branch and short sha code. i.e., make launch-dsl-bps DSL_BP=karbon_admin_ws
	@make -C dsl/${DSL_BP} launch-bp

delete-dsl-bps: ### Delete Blueprint that matches your git feature branch and short sha code. i.e., make delete-dsl-bps DSL_BP=karbon_admin_ws
	@make -C dsl/${DSL_BP} delete-bp

delete-dsl-apps: ### Delete Application that matches your git feature branch and short sha code. i.e., make delete-dsl-apps DSL_BP=karbon_admin_ws
	@make -C dsl/${DSL_BP} delete-app

## RELEASE MANAGEMENT

## Following should be run from master branch along with git tag v1.0.x-$(git rev-parse --short HEAD), git push origin --tags, validate with git tag -l

# If needing to publish from a previous commit/tag than current master HEAD, from master, run git reset --hard tagname to set local working copy to that point in time.
# Run git reset --hard origin/master to return your local working copy back to latest master HEAD.

publish-new-dsl-bps publish-existing-dsl-bps unpublish-dsl-bps: init-dsl-config

publish-new-dsl-bps: ### First Time Publish of Standard DSL BP. i.e., make publish-new-dsl-bps DSL_BP=karbon_admin_ws
	# promote stable release to marketplace for new
	@make -C dsl/${DSL_BP} publish-new-bp

publish-existing-dsl-bps: ### Publish Standard DSL BP of already existing. i.e., make publish-existing-dsl-bps DSL_BP=karbon_admin_ws
	# promote stable release to marketplace for existing
	@make -C dsl/${DSL_BP} publish-existing-bp

unpublish-dsl-bps: ### UnPublish Standard DSL BP of already existing. i.e., make unpublish-dsl-bps DSL_BP=karbon_admin_ws
	# promote stable release to marketplace for existing
	@make -k -C dsl/${DSL_BP} unpublish-bp

## Helm charts specific commands

create-helm-bps launch-helm-bps delete-helm-bps delete-helm-apps publish-new-helm-bps publish-existing-helm-bps unpublish-helm-bps: init-dsl-config

create-helm-bps: ### Create single helm chart bp (with current git branch / tag latest in name). i.e., make create-helm-bps CHART=argocd
	# create helm bp with corresponding git feature branch and short sha code
	@make -C dsl/helm_charts/${CHART} create-bp

launch-helm-bps: ### Launch single helm chart app (with current git branch / tag latest in name). i.e., make launch-helm-bps CHART=argocd
	# launch helm bp that matches your git feature branch and short sha code
	@make -C dsl/helm_charts/${CHART} launch-bp

delete-helm-bps: ### Delete single helm chart blueprint (with current git branch / tag latest in name). i.e., make delete-helm-bps CHART=argocd
	# delete helm bp that matches your git feature branch and short sha code
	@make -C dsl/helm_charts/${CHART} delete-bp

delete-helm-apps: ### Delete single helm chart app (with current git branch / tag latest in name). i.e., make delete-helm-apps CHART=argocd
	# delete helm app that matches your git feature branch and short sha code
	@make -C dsl/helm_charts/${CHART} delete-app

create-all-helm-charts: ### Create all helm chart blueprints with default test parameters (with current git branch / tag latest in name)
	ls dsl/helm_charts | xargs -I {} make create-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

launch-all-helm-charts: ### Launch all helm chart blueprints with default test parameters (with current git branch / tag latest in name)
	ls dsl/helm_charts | grep -v -E "metallb|ingress-nginx|cert-manager" | xargs -I {} make launch-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

delete-all-helm-charts-apps: ### Delete all helm chart apps (with current git branch / tag latest in name)
	# remove pre-reqs last
	ls dsl/helm_charts | grep -v -E "metallb|ingress-nginx|cert-manager" | xargs -I {} make delete-helm-apps ENVIRONMENT=${ENVIRONMENT} CHART={}
	make delete-helm-apps CHART=ingress-nginx ENVIRONMENT=${ENVIRONMENT}
	make delete-helm-apps CHART=cert-manager ENVIRONMENT=${ENVIRONMENT}
	make delete-helm-apps CHART=metallb ENVIRONMENT=${ENVIRONMENT}

delete-all-helm-charts-bps: ### Delete all helm chart blueprints (with current git branch / tag latest in name)
	ls dsl/helm_charts | xargs -I {} make delete-helm-bps CHART={} ENVIRONMENT=${ENVIRONMENT}


## RELEASE MANAGEMENT

## Following should be run from master branch along with git tag v1.0.x-$(git rev-parse --short HEAD), git push origin --tags, validate with git tag -l

# If needing to publish from a previous commit/tag than current master HEAD, from master, run git reset --hard tagname to set local working copy to that point in time.
# Run git reset --hard origin/master to return your local working copy back to latest master HEAD.

publish-new-helm-bps: ### First Time Publish of Single Helm Chart. i.e., make publish-new-helm-bps CHART=argocd
	# promote stable release to marketplace for new
	@make -C dsl/helm_charts/${CHART} publish-new-bp

publish-existing-helm-bps: ### Publish Single Helm Chart of already existing Helm Chart. i.e., make publish-existing-helm-bps CHART=argocd
	# promote stable release to marketplace for existing
	@make -C dsl/helm_charts/${CHART} publish-existing-bp

unpublish-helm-bps: ### Unpublish Single Helm Chart Blueprint - latest git release. i.e., make unpublish-helm-bps CHART=argocd
	# unpublish stable release to marketplace for existing
	@make -k -C dsl/helm_charts/${CHART} unpublish-bp

publish-all-new-helm-bps: ### First Time Publish of ALL Helm Chart Blueprints into Marketplace
	ls dsl/helm_charts | xargs -I {} make publish-new-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

publish-all-existing-helm-bps: ### Publish New Version of all existing helm chart marketplace items with latest git release.
	ls dsl/helm_charts | xargs -I {} make publish-existing-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

unpublish-all-helm-bps: ### Unpublish all Helm Chart Blueprints of latest git release (i.e., git tag --list)
	ls dsl/helm_charts | xargs -I {} make unpublish-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

##############
## Helpers

.PHONY: print-vars
print-vars: ### Print environment variables. i.e., make print-vars ENVIRONMENT={environment_folder_name}
	@for envvar in $$(cat $(ENV_GLOBAL_PATH) $(ENV_OVERRIDE_PATH) | cut -d= -f1 | sort -usf | xargs -n 1); do `echo env` | grep -vi "pass" | grep "$$envvar=" 2>/dev/null; done; 2>/dev/null

.PHONY: print-secrets
print-secrets: ### Print variables including secrets. i.e., make print-secrets ENVIRONMENT={environment_folder_name}
	@for envvar in $$(cat $(ENV_GLOBAL_PATH) $(ENV_OVERRIDE_PATH) | cut -d= -f1 | sort -usf | xargs -n 1); do `echo env` | egrep -i "user|pass|key" | grep "$$envvar=" 2>/dev/null; done; 2>/dev/null

.DEFAULT_GOAL := help
.PHONY: help
help: ### Show this help
	@egrep -h '\s###\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?### "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

####
## Configure Local KUBECTL config and ssh keys for Karbon
####

.PHONY: download-karbon-creds
download-karbon-creds: ### Leverage karbon krew/kubectl plugin to login and download config and ssh keys
	@kubectl-karbon login -k --server ${PC_IP_ADDRESS} --cluster ${KARBON_CLUSTER} --user admin --kubeconfig ~/.kube/${KARBON_CLUSTER}.cfg --force
	make merge-kubectl-contexts

.PHONY: merge-kubectl-contexts
merge-kubectl-contexts: ### Merge all K8s cluster kubeconfigs within path to config file.  Needed to support multiple clusters in future
	export KUBECONFIG=$$KUBECONFIG:~/.kube/${KARBON_CLUSTER}.cfg; \
		kubectl config view --flatten >| ~/.kube/config;
	kubectl config use-context ${KUBECTL_CONTEXT};
	kubectl cluster-info

.PHONY: fix-dockerhub-pull-secrets
fix-dockerhub-pull-secrets: ### Add docker hub secret to get around image download rate limiting issues
	kubectl get ns -o name | cut -d / -f2 | xargs -I {} kubectl create secret docker-registry myregistrykey --docker-username=${DOCKER_HUB_USER} --docker-password=${DOCKER_HUB_PASS} -n {}
	kubectl get serviceaccount --no-headers --all-namespaces | awk '{print $1,$2}' | xargs -n2 sh -c 'kubectl patch serviceaccount $2 -p "{\"imagePullSecrets\": [{\"name\": \"myregistrykey\"}]}" -n $1' sh
