.ONESHELL:

ENVIRONMENT ?= kalm-main-16-4
DEFAULT_SHELL ?= /bin/zsh

IMAGE_REGISTRY_ORG = ghcr.io/jesse-gonzalez

## load common variables and anything environment specific that overrides
export ENV_GLOBAL_PATH 	 := $(CURDIR)/config/_common/.env
export ENV_OVERRIDE_PATH := $(CURDIR)/config/${ENVIRONMENT}/.env

## execute gpg import and include environment variables only when running in container
ifneq ("$(wildcard /.dockerenv)","")
	GPG_IMPORT = $(shell find .local -name sops_gpg_key | egrep -i "common|${ENVIRONMENT}" | xargs -I {} gpg --quiet --import {} 2>/dev/null)
	include $(ENV_GLOBAL_PATH)
	-include $(ENV_OVERRIDE_PATH)
endif

## export all vars
export

REQUIRED_TOOLS_LIST := docker git make
CHECK_TOOLS := $(foreach tool,$(REQUIRED_TOOLS_LIST), $(if $(shell which $(tool)),some string,$(error "No $(tool) in PATH")))

####
## Configure Calm DSL and Docker Container
####

docker-build: ### Build Calm DSL Util Image locally with necessary tools to develop and manage Cloud-Native Apps (e.g., kubectl, argocd, git, helm, helmfile, etc.)
	@docker image ls --filter "reference=${IMAGE_REGISTRY_ORG}/calm-dsl-utils" --format "{{.Repository}}:{{.ID}}" | xargs -I {} docker rmi -f {}
	@docker build -t ${IMAGE_REGISTRY_ORG}/calm-dsl-utils:latest .

docker-push: docker-login ### Tag and Push latest image and short sha version to desired image repo.
	[ -n "$$(docker image ls ${IMAGE_REGISTRY_ORG}/calm-dsl-utils -q)" ] || make docker-build
	@docker push ${IMAGE_REGISTRY_ORG}/calm-dsl-utils:latest
	@docker tag ${IMAGE_REGISTRY_ORG}/calm-dsl-utils ${IMAGE_REGISTRY_ORG}/calm-dsl-utils:$(GIT_COMMIT_ID)
	@docker push ${IMAGE_REGISTRY_ORG}/calm-dsl-utils:$(GIT_COMMIT_ID)

docker-run: ### Launch into Calm DSL development container. If image isn't available, build will auto-run
	[ -n "$$(docker image ls ${IMAGE_REGISTRY_ORG}/calm-dsl-utils -q)" ] || docker pull ${IMAGE_REGISTRY_ORG}/calm-dsl-utils:latest
	# this will exec you into the interactive container
	@docker run --rm -it \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v `pwd`:/dsl-workspace \
		-w '/dsl-workspace' \
		-e ENVIRONMENT='${ENVIRONMENT}' \
		${IMAGE_REGISTRY_ORG}/calm-dsl-utils /bin/sh -c "${DEFAULT_SHELL}"

check-dsl-init: ### Validate whether calm init dsl needs to be executed with target environment.
	# validating that you're inside docker container.  If you were just put into container, you may need to re-run last command
	[ -f /.dockerenv ] || make docker-run ENVIRONMENT=${ENVIRONMENT};
	@calm get apps -o json 2>/dev/null > config/{}/nutanix.ncmstate;
	@export DSL_ACCOUNT_IP=$(shell calm describe account NTNX_LOCAL_AZ | grep 'IP' | cut -d: -f2 | tr -d " " 2>/dev/null); \
		[ "$$DSL_ACCOUNT_IP" == "${PC_IP_ADDRESS}" ] || make init-dsl-config ENVIRONMENT=${ENVIRONMENT};

init-dsl-config: print-vars ### Initialize calm dsl configuration with environment specific configs.  Assumes that it will be running withing Container.
	# validating that you're inside docker container.  If you were just put into container, you may need to re-run last command
	[ -f /.dockerenv ] || make docker-run ENVIRONMENT=${ENVIRONMENT};
	@mkdir -p ${CALM_DSL_LOCAL_DIR_LOCATION} && cp -rf .local/* /root/.calm
	@touch ${CALM_DSL_CONFIG_FILE_LOCATION} ${CALM_DSL_DB_LOCATION}
	@calm init dsl --project "${CALM_PROJECT}";

## Common BP command based on DSL_BP path passed in. To Run, make create-dsl-bps <dsl_bp_folder_name>

create-dsl-bps launch-dsl-bps delete-dsl-bps delete-dsl-apps: init-dsl-config

create-dsl-bps: ### Create bp with corresponding git feature branch and short sha code. i.e., make create-dsl-bps DSL_BP=bastion_host_svm ENVIRONMENT=${ENVIRONMENT}
	@make -C dsl/blueprints/${DSL_BP} create-bp

launch-dsl-bps: ### Launch Blueprint that matches your git feature branch and short sha code. i.e., make launch-dsl-bps DSL_BP=bastion_host_svm ENVIRONMENT=${ENVIRONMENT}
	@make -C dsl/blueprints/${DSL_BP} launch-bp

delete-dsl-bps: ### Delete Blueprint that matches your git feature branch and short sha code. i.e., make delete-dsl-bps DSL_BP=bastion_host_svm ENVIRONMENT=${ENVIRONMENT}
	@make -C dsl/blueprints/${DSL_BP} delete-bp

delete-dsl-apps: ### Delete Application that matches your git feature branch and short sha code. i.e., make delete-dsl-apps DSL_BP=bastion_host_svm ENVIRONMENT=${ENVIRONMENT}
	@make -C dsl/blueprints/${DSL_BP} delete-app

## RELEASE MANAGEMENT

## Following should be run from master branch along with git tag v1.0.x-$(git rev-parse --short HEAD), git push origin --tags, validate with git tag -l

publish-new-dsl-bps publish-existing-dsl-bps unpublish-dsl-bps: check-dsl-init

publish-new-dsl-bps: ### First Time Publish of Standard DSL BP. i.e., make publish-new-dsl-bps DSL_BP=bastion_host_svm ENVIRONMENT=${ENVIRONMENT}
	@make -C dsl/blueprints/${DSL_BP} publish-new-bp

publish-existing-dsl-bps: ### Publish Standard DSL BP of already existing. i.e., make publish-existing-dsl-bps DSL_BP=bastion_host_svm ENVIRONMENT=${ENVIRONMENT}
	@make -C dsl/blueprints/${DSL_BP} publish-existing-bp

unpublish-dsl-bps: ### UnPublish Standard DSL BP of already existing. i.e., make unpublish-dsl-bps DSL_BP=bastion_host_svm ENVIRONMENT=${ENVIRONMENT}
	@make -k -C dsl/blueprints/${DSL_BP} unpublish-bp

## Helm charts specific commands

create-helm-bps launch-helm-bps delete-helm-bps delete-helm-apps publish-new-helm-bps publish-existing-helm-bps unpublish-helm-bps: check-dsl-init

create-helm-bps: ### Create single helm chart bp (with current git branch / tag latest in name). i.e., make create-helm-bps CHART=argocd ENVIRONMENT=${ENVIRONMENT}
	@make -C dsl/blueprints/helm_charts/${CHART} create-bp

launch-helm-bps: ### Launch single helm chart app (with current git branch / tag latest in name). i.e., make launch-helm-bps CHART=argocd ENVIRONMENT=${ENVIRONMENT}
	@make -C dsl/blueprints/helm_charts/${CHART} launch-bp

delete-helm-bps: ### Delete single helm chart blueprint (with current git branch / tag latest in name). i.e., make delete-helm-bps CHART=argocd ENVIRONMENT=${ENVIRONMENT}
	@make -C dsl/blueprints/helm_charts/${CHART} delete-bp

delete-helm-apps: ### Delete single helm chart app (with current git branch / tag latest in name). i.e., make delete-helm-apps CHART=argocd ENVIRONMENT=${ENVIRONMENT}
	@make -C dsl/blueprints/helm_charts/${CHART} delete-app

create-all-helm-charts: ### Create all helm chart blueprints with default test parameters (with current git branch / tag latest in name). i.e., make create-all-helm-charts ENVIRONMENT=${ENVIRONMENT}
	ls dsl/blueprints/helm_charts | xargs -I {} make create-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

launch-all-helm-charts: ### Launch all helm chart blueprints with default test parameters (minus already deployed charts). i.e., make launch-all-helm-charts ENVIRONMENT=${ENVIRONMENT}
	ls dsl/blueprints/helm_charts | grep -v -E "kyverno|metallb|ingress-nginx|cert-manager" | xargs -I {} make launch-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

delete-all-helm-apps: ### Delete all helm chart apps (with current git branch / tag latest in name). i.e., make delete-helm-apps ENVIRONMENT=kalm-main-16-1
	# remove pre-reqs last
	ls dsl/blueprints/helm_charts | grep -v -E "kyverno|metallb|ingress-nginx|cert-manager" | xargs -I {} make delete-helm-apps ENVIRONMENT=${ENVIRONMENT} CHART={}
	@make delete-helm-apps CHART=ingress-nginx ENVIRONMENT=${ENVIRONMENT}
	@make delete-helm-apps CHART=cert-manager ENVIRONMENT=${ENVIRONMENT}
	@make delete-helm-apps CHART=metallb ENVIRONMENT=${ENVIRONMENT}

delete-all-helm-bps: ### Delete all helm chart blueprints (with current git branch / tag latest in name)
	ls dsl/blueprints/helm_charts | xargs -I {} make delete-helm-bps CHART={} ENVIRONMENT=${ENVIRONMENT}

## Endpoint specific commands

create-dsl-endpoint create-all-dsl-endpoints: check-dsl-init

create-dsl-endpoint: ### Create Endpoint Resource. i.e., make create-dsl-endpoint EP=bastion_host_svm ENVIRONMENT=kalm-main-16-1
	@calm create endpoint -f ./dsl/endpoints/${EP}/endpoint.py --name ${EP} -fc 

create-all-dsl-endpoints: ### Create ALL Endpoint Resources. i.e., make create-all-dsl-endpoints ENVIRONMENT=kalm-main-16-1
	ls dsl/endpoints | xargs -I {} make create-dsl-endpoint EP={} ENVIRONMENT=${ENVIRONMENT}

## Runbook specific commands

create-dsl-runbook create-all-dsl-runbooks run-dsl-runbook run-all-dsl-runbook-scenarios: check-dsl-init

create-dsl-runbook: ### Create Runbook. i.e., make create-dsl-runbook RUNBOOK=update_ad_dns ENVIRONMENT=kalm-main-16-1
	@calm create runbook -f ./dsl/runbooks/${RUNBOOK}/runbook.py --name ${RUNBOOK} -fc 

create-all-dsl-runbooks: ### Create ALL Endpoint Resources. i.e., make create-all-dsl-runbooks ENVIRONMENT=kalm-main-16-1
	ls dsl/runbooks | xargs -I {} make create-dsl-runbook RUNBOOK={} ENVIRONMENT=${ENVIRONMENT}

run-dsl-runbook: ### Run Runbook with Specific Scenario. i.e., make run-dsl-runbook RUNBOOK=update_ad_dns SCENARIO=create_ingress_dns_params ENVIRONMENT=kalm-main-16-1
	@calm run runbook -i --input-file ./dsl/runbooks/${RUNBOOK}/init-scenarios/${SCENARIO}.py ${RUNBOOK}

run-all-dsl-runbook-scenarios: ### Runs all dsl runbook scenarios for given runbook i.e., make run-all-dsl-runbook-scenarios RUNBOOK=update_objects_bucket ENVIRONMENT=kalm-main-16-1
	@ls dsl/runbooks/${RUNBOOK}/init-scenarios/*.py | cut -d/ -f5 | cut -d. -f1 | xargs -I {} make run-dsl-runbook RUNBOOK=${RUNBOOK} SCENARIO={}

## WORKFLOWS

init-bastion-host-svm init-runbook-infra init-kalm-cluster init-helm-charts publish-all-blueprints bootstrap-reset-all: check-dsl-init

init-bastion-host-svm: ### Initialize Karbon Admin Bastion Workstation. .i.e., make init-bastion-host-svm ENVIRONMENT=kalm-main-16-1
	@make create-dsl-bps launch-dsl-bps DSL_BP=bastion_host_svm ENVIRONMENT=${ENVIRONMENT};
	@make set-bastion-host ENVIRONMENT=${ENVIRONMENT};

set-bastion-host: ### Update Dynamic IP for Linux Bastion Endpoint. .i.e., make set-bastion-host ENVIRONMENT=kalm-main-16-1
	@export BASTION_HOST_SVM_IP=$(shell calm get apps -n bastion-host-svm -q -l 1 | xargs -I {} calm describe app {} -o json | jq '.status.resources.deployment_list[0].substrate_configuration.element_list[0].address' | tr -d '"'); \
		grep -i BASTION_HOST_SVM_IP $(ENV_OVERRIDE_PATH) && sed -i "s/BASTION_HOST_SVM_IP =.*/BASTION_HOST_SVM_IP = $$BASTION_HOST_SVM_IP/g" $(ENV_OVERRIDE_PATH) || echo -e "BASTION_HOST_SVM_IP = $$BASTION_HOST_SVM_IP" >> $(ENV_OVERRIDE_PATH);

init-runbook-infra: ### Initialize Calm Shared Infra from Endpoint, Runbook and Supporting Blueprints perspective. .i.e., make init-runbook-infra ENVIRONMENT=kalm-main-16-1
	@make set-bastion-host ENVIRONMENT=${ENVIRONMENT};
	@make create-all-dsl-endpoints ENVIRONMENT=${ENVIRONMENT};
	@make create-all-dsl-runbooks ENVIRONMENT=${ENVIRONMENT};
	@make run-all-dsl-runbook-scenarios RUNBOOK=update_calm_categories ENVIRONMENT=${ENVIRONMENT};
	@make run-all-dsl-runbook-scenarios RUNBOOK=update_ad_dns ENVIRONMENT=${ENVIRONMENT};
	@make run-all-dsl-runbook-scenarios RUNBOOK=update_objects_bucket ENVIRONMENT=${ENVIRONMENT};

init-helm-charts: ### Intialize Helm Chart Marketplace. i.e., make init-helm-charts ENVIRONMENT=kalm-main-16-1
	@make create-all-helm-charts ENVIRONMENT=${ENVIRONMENT};

init-kalm-cluster: ### Initialize Karbon Cluster. i.e., make init-kalm-cluster ENVIRONMENT=kalm-main-16-1
	@make set-bastion-host ENVIRONMENT=${ENVIRONMENT};
	@make run-all-dsl-runbook-scenarios RUNBOOK=update_ad_dns ENVIRONMENT=${ENVIRONMENT};
	@make download-karbon-cfgs ENVIRONMENT=${ENVIRONMENT};
	@make create-dsl-bps launch-dsl-bps DSL_BP=karbon_cluster_deployment ENVIRONMENT=${ENVIRONMENT};

publish-all-blueprints: ### Publish all stable helm charts and blueprints
ifeq ($(MP_GIT_TAG),$(shell calm get marketplace bps 2>/dev/null | grep LOCAL | grep -v ExpressLaunch | cut -d "|" -f8 | uniq | tail -n1 | xargs))
	@make unpublish-all-blueprints ENVIRONMENT=${ENVIRONMENT};
endif
ifneq ($(shell calm get marketplace bps 2>/dev/null | grep LOCAL | grep -v ExpressLaunch | cut -d "|" -f8 | uniq | tail -n1 | xargs),)
	@make publish-existing-dsl-bps DSL_BP=set-bastion-host ENVIRONMENT=${ENVIRONMENT};
	@make publish-existing-dsl-bps DSL_BP=karbon_cluster_deployment ENVIRONMENT=${ENVIRONMENT};
	@make publish-all-existing-helm-bps ENVIRONMENT=${ENVIRONMENT};
else
	@make publish-new-dsl-bps DSL_BP=set-bastion-host ENVIRONMENT=${ENVIRONMENT};
	@make publish-new-dsl-bps DSL_BP=karbon_cluster_deployment ENVIRONMENT=${ENVIRONMENT};
	@make publish-all-new-helm-bps ENVIRONMENT=${ENVIRONMENT};
endif

unpublish-all-blueprints: ### Un-publish all marketplace items and delete marketplace blueprints (and un-used app icons) for current git tag version.
	@calm get marketplace items -d -q | xargs -I {} -t sh -c "calm unpublish marketplace bp -v ${MP_GIT_TAG} -s LOCAL {} && calm delete marketplace bp {} -v ${MP_GIT_TAG}";
	@calm get marketplace bps | grep -i ${MP_GIT_TAG} | awk '{ print $$2 }' | xargs -I {} -t sh -c "calm delete marketplace bp {} -v ${MP_GIT_TAG}";
	@calm get app_icons --limit 50 --marketplace_use | grep -i false  | awk '{ print $$2 }' | xargs -I {} -t sh -c "calm delete app_icon {}";

bootstrap-kalm-all: ### Bootstrap Bastion Host, Shared Infra and Karbon Cluster. i.e., make bootstrap-kalm-all ENVIRONMENT=kalm-main-16-1
	@make init-dsl-config ENVIRONMENT=${ENVIRONMENT};
	@make bootstrap-reset-all ENVIRONMENT=${ENVIRONMENT};
	@make init-bastion-host-svm ENVIRONMENT=${ENVIRONMENT};
	@make init-runbook-infra ENVIRONMENT=${ENVIRONMENT};
	@make init-kalm-cluster ENVIRONMENT=${ENVIRONMENT};
	@make create-all-helm-charts ENVIRONMENT=${ENVIRONMENT};
	@make publish-all-blueprints ENVIRONMENT=${ENVIRONMENT};

bootstrap-reset-all: ## Reset Environment Configurations that can't be easily overridden (i.e., excludes blueprints,endpoints,runbooks)
	@calm get apps --limit 50 -q --filter=_state==provisioning | grep -v "No application found" | xargs -I {} -t sh -c "calm stop app {} --watch 2>/dev/null";
	@calm get apps --limit 50 -q --filter=_state==deleting | grep -v "No application found" | xargs -I {} -t sh -c "calm stop app {} --watch 2>/dev/null";
	@calm get apps --limit 50 -q --filter=_state==error | grep -v "No application found" | xargs -I {} -t sh -c "calm delete app {}";
	@calm get apps --limit 50 -q | egrep -v "karbon|bastion" | grep -v "No application found" | xargs -I {} -t sh -c "calm delete app --soft {}";
	@calm get apps -q -n karbon | grep -v "No application found" | xargs -I {} -t sh -c "calm delete app {}";
	@calm get apps -q -n bastion | grep -v "No application found" | xargs -I {} -t sh -c "calm delete app {}";
	@calm get bps --limit 50 -q | grep -v "No blueprint found" | xargs -I {} -t sh -c "calm delete bp {}";
	@calm get runbooks -q | grep -v "No runbook found" | xargs -I {} -t sh -c "calm delete runbook {}";
	@calm get endpoints -q | grep -v "No endpoint found" | xargs -I {} -t sh -c "calm delete endpoint {}";

launch-gitops-stack:
	@calm launch-helm-chart 

## RELEASE MANAGEMENT

## Following should be run from master branch along with git tag v1.0.x-$(git rev-parse --short HEAD), git push origin --tags, validate with git tag -l

# If needing to publish from a previous commit/tag than current master HEAD, from master, run git reset --hard tagname to set local working copy to that point in time.
# Run git reset --hard origin/master to return your local working copy back to latest master HEAD.

publish-new-helm-bpsm publish-existing-helm-bps unpublish-helm-bps publish-all-new-helm-bps publish-all-existing-helm-bps unpublish-all-helm-bps: check-dsl-init

promote-release: github-login ## Promote next version of git tag
	@git fetch --tags
	@echo "VERSION:$(GIT_VERSION) IS_SNAPSHOT:$(GIT_IS_SNAPSHOT) NEW_VERSION:$(GIT_NEW_VERSION)"
ifeq (false,$(GIT_IS_SNAPSHOT))
	@echo "Unable to promote a non-snapshot"
	@exit 1
endif
ifneq ($(shell git status -s),)
	@echo "Unable to promote a dirty workspace. Please commit and push your updates"
	@exit 1
endif
	@git tag -a -m "releasing v$(GIT_NEW_VERSION)" v$(GIT_NEW_VERSION)
	@git push origin v$(GIT_NEW_VERSION)

publish-new-helm-bps: ### First Time Publish of Single Helm Chart. i.e., make publish-new-helm-bps CHART=argocd
	# promote stable release to marketplace for new
	@make -C dsl/blueprints/helm_charts/${CHART} publish-new-bp

publish-existing-helm-bps: ### Publish Single Helm Chart of already existing Helm Chart. i.e., make publish-existing-helm-bps CHART=argocd
	# promote stable release to marketplace for existing
	@make -C dsl/blueprints/helm_charts/${CHART} publish-existing-bp

unpublish-helm-bps: ### Unpublish Single Helm Chart Blueprint - latest git release. i.e., make unpublish-helm-bps CHART=argocd
	# unpublish stable release to marketplace for existing
	@make -k -C dsl/blueprints/helm_charts/${CHART} unpublish-bp

publish-all-new-helm-bps: ### First Time Publish of ALL Helm Chart Blueprints into Marketplace
	@ls dsl/blueprints/helm_charts | xargs -I {} make publish-new-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

publish-all-existing-helm-bps: ### Publish New Version of all existing helm chart marketplace items with latest git release.
	@ls dsl/blueprints/helm_charts | xargs -I {} make publish-existing-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

unpublish-all-helm-bps: ### Unpublish all Helm Chart Blueprints of latest git release (i.e., git tag --list)
	ls dsl/blueprints/helm_charts | xargs -I {} make unpublish-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

##############
## Helpers

print-vars: ### Print environment variables. i.e., make print-vars ENVIRONMENT={environment_folder_name}
	@for envvar in $$(cat $(ENV_GLOBAL_PATH) $(ENV_OVERRIDE_PATH) | cut -d= -f1 | sort -usf | xargs -n 1); do `echo env` | egrep -vi "USER|PASS|KEY|SECRET|CRED|TOKEN" | grep "$$envvar=" 2>/dev/null; done; 2>/dev/null

print-secrets: ### Print variables including secrets. i.e., make print-secrets ENVIRONMENT={environment_folder_name}
	@for envvar in $$(cat $(ENV_GLOBAL_PATH) $(ENV_OVERRIDE_PATH) | cut -d= -f1 | sort -usf | xargs -n 1); do `echo env` | egrep "USER|PASS|KEY|SECRET|CRED|TOKEN" | grep "$$envvar=" 2>/dev/null; done; 2>/dev/null

.DEFAULT_GOAL := help
help: ### Show this help
	@egrep -h '\s###\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?### "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

docker-login: ## Login to Container Private Registry
	@echo "$(DOCKER_HUB_PASS)" | docker login --username $(DOCKER_HUB_USER) --password-stdin

github-login: ## Login to GitHub Repo to support local commits and tag promotion
	@echo -e "$(GITHUB_PASS)" | gh auth login --with-token
	@gh auth setup-git;
	@git config user.name "$(GITHUB_USER)";
	@git config user.email "$(GITHUB_EMAIL)";

####
## Configure Local KUBECTL config and ssh keys for Karbon
####

download-karbon-creds download-all-karbon-cfgs fix-image-pull-secrets: check-dsl-init

download-karbon-creds: ### Leverage karbon krew/kubectl plugin to login and download config and ssh keys
	@KARBON_PASSWORD=${PC_PASSWORD} kubectl-karbon login -k --server ${PC_IP_ADDRESS} --cluster ${KARBON_CLUSTER} --user ${PC_USER} --kubeconfig ~/.kube/${KARBON_CLUSTER}.cfg --force
	@make merge-kubectl-contexts

merge-kubectl-contexts: ### Merge all K8s cluster kubeconfigs within path to config file.  Needed to support multiple clusters in future
	@export KUBECONFIG=$$KUBECONFIG:~/.kube/${KARBON_CLUSTER}.cfg; \
		kubectl config view --flatten >| ~/.kube/config && chmod 600 ~/.kube/config;
	@kubectl config use-context ${KUBECTL_CONTEXT};
	@kubectl cluster-info

download-all-karbon-cfgs: ### Download all kubeconfigs from all environments that have Karbon Cluster running
	@ls config/*/nutanix.ncmstate | cut -d/ -f2 | xargs -I {} sh -c 'jq -r ".entities[].status | select((.description | contains(\"karbon-clusters\")) and (.state == \"running\")) | .name " config/{}/nutanix.ncmstate' \
		| xargs -I {} grep -l {} config/*/nutanix.ncmstate | cut -d/ -f2 | xargs -I {} make download-karbon-creds ENVIRONMENT={} && echo "reload shell. i.e., source ~/.zshrc and run kubectx to switch clusters"

fix-image-pull-secrets: ### Add image pull secret to get around image download rate limiting issues
	@kubectl get ns -o name | cut -d / -f2 | xargs -I {} sh -c "kubectl create secret docker-registry image-pull-secret --docker-username=${DOCKER_HUB_USER} --docker-password=${DOCKER_HUB_PASS} -n {} --dry-run=client -o yaml | kubectl apply -f - "
	@kubectl get serviceaccount --no-headers --all-namespaces | awk '{ print $$1 , $$2 }' | xargs -n2 sh -c 'kubectl patch serviceaccount $$2 -p "{\"imagePullSecrets\": [{\"name\": \"image-pull-secret\"}]}" -n $$1' sh

seed-calm-task-library: ### Seed the calm task library from nutanix blueprints github repo. make seed-calm-task-library ENVIRONMENT=kalm-main-16-1
	@rm -rf /tmp/blueprints
	@git clone https://github.com/nutanix/blueprints.git /tmp/blueprints
	@cd /tmp/blueprints/calm-integrations/generate_task_library_items
	@bash generate_task_library_items.sh

run-gh-workflow-dispatch: github-login ### Run github actions dispatch workflow with common params. Github Repo admins only
	gh workflow run github-actions.yml --ref ${GIT_BRANCH_NAME} -f deploy_environment=${ENVIRONMENT} -f github_environment=kalm-main-common -f github_runner=kalm-main-runners