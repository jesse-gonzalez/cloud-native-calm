# Cloud Native Calm DSL Blueprints

The purpose of this repo is to seed any Nutanix Prism Central environment with a collection of curated Calm Blueprints used to standup a production ready Kubernetes distribution and subsequently customize it with one of the many kubernetes applications that are available in the Self-Service Marketplace items

This repo was built after our team had issues with the shared cluster being used for demonstrations.  These types of issues lead to critical customer meeting cancellations and a significant loss of time / productivity.

In any case, as I was porting our existing stuff to some interim cluster, I realized that this will most likely not be the last time that this will happen, so in light of being a considerate `infrastructure as code` citizen, I decided to treat the demo lab more like a "cattle" environment versus a "pet".

## Pre-Requisites

* Nutanix Prism Central
* Nutanix AHV Cluster
* Nutanix Calm (Self-Service/Nutanix Cloud Manager)
* Nutanix Karbon Enabled (Nutanix Kubernetes Engine)
* [Optional] Nutanix Objects Enabled 
  * User/Access Key Generated
* [Optional] Nutanix Files Enabled
* Docker Desktop
* Git
* Make
* jq
* ssh-keys: [Generating SSH Key on a Linux VM](https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Calm-Admin-Operations-Guide-v3_5_1:nuc-app-mgmt-generate-private-key-t.html)

## What is the purpose of this repo?

Since many customers are very visual and prefer to see the technologies they have in-house being leveraged for the underlying demo / presentation, we went ahead and began developing a curated listed of blueprints that could deploy some the most highly requested cloud-native technologes using Helm Kubernetes package manager.

Alternatively, having a space that is highly transient and ephemeral in nature lends to being an environment where folks can do highly destructive testing with no fear or hesitation...goes without saying - `FAILING FAST is instrumental to lean, repeatable and qualitative results!!`

![kalm-marketplace](docs/images/kalm-marketplace.png)

### 1. Karbon Focused - Helm Chart Marketplace

Since this repository is highly focused on Nutanix Karbon and Calm integration, the goal was to be able to provide a means of deploying the respective Helm charts on any Karbon Cluster that is currently deployed into the respective Prism Central instance.  The only pre-requisite is that the running cluster already has MetalLB, Ingress and Cert-Manager.  Alternatively, one can demo the Calm blueprint that actually deploys the underlying Karbon cluster with all the pre-requisites already deployed / configured.

1. Curated list of Helm Chart Deployments of various cloud-native solutions (vetted as part of the CNCF) that have allowed us to quickly plug and play based on customer needs
1. All Helm Chart Blueprints fully published to Calm Marketplace, with option to only create / publish each blueprint independently.
1. Each Helm Chart is designed to be easily deployed onto any Karbon cluster, with HTTPS and Ingress fully configured using optional Wildcard DNS.
1. In certain cases, Helm Charts are deployed and configured with advanced scenarios to demonstrate real world use cases. (i.e., Deploy JFrog Container Registry -> Configure Docker and Helm Repositories -> Configure Karbon Private Registry)

![kalm-marketplace_helm](docs/images/kalm-marketplace_helm.png)

### 2. Karbon Cluster Deployment Blueprint

The purpose of this blueprint was to demonstrate how customers can leverage Calm and the underlying Karbon APIs to easily Deploy either a Development and/or Production Cluster, while also laying down the base components needed to be productive with well-known karbon/kubernetes command line utilities with a development workstation and lastly, deploying the MetalLB, Cert-Manager and Ingress components needed for most underlying Helm Charts.

![karbon-bp](docs/images/karbon-bp.png)

### 3. Alternative CNCF Certified - Managed Kubernetes Distributions

The purpose of these blueprints is to demonstrate how Calm can also be leveraged to automate the provisioning of just about ANY alternative K8s distributions - such as `Google Anthos`, `RKE`, `RKE2 (Rancher Federal)`, `Azure Arc`, `RedHat Openshift`, etc.  If a customer is already leveraging an alternative solution, 9 times out of 10, you can demonstrate how much easier it was to get around the initial complexities around first deploying the underlying virtual infrastructure (e.g., machine images, persistent storage, DNS, etc.) needed to bootstrap the respective managed distribution, especially in a highly availble production ready state.

As part of the initial deployment, Calm will also provision the latest Nutanix CSI driver as a means of enabling end users / developers to consume persistent volumes made available via Nutanix Volumes, Files and/or Objects - DAY ONE.  Finally, to drive the topic home, you'll be able demonstrate how Calm's native lifecycle capabilities to support Custom DAY TWO actions will allow the end users to subsequently manage out the complexity around scaling in and out the underlying K8s worker nodes and possibly performing a rolling upgrade of the respective distribution in a fully self-service manner.

## Setup Local Development Environment

1. Clone repo and change directory (cd):

  ```bash
    git clone https://github.com/nutanix-enterprise/shared-demo-karbon-calm.git
    cd shared-demo-karbon-calm
  ```

1. Review `make help` to see the various options that can be executed via make command.

```bash
❯ make help                                                                                                                                                                                     ─╯
bootstrap-kalm-all   Bootstrap All
create-all-dsl-endpoints Create ALL Endpoint Resources. i.e., make create-all-dsl-endpoints
create-all-dsl-runbooks Create ALL Endpoint Resources. i.e., make create-all-dsl-runbooks
create-all-helm-charts Create all helm chart blueprints with default test parameters (with current git branch / tag latest in name)
create-dsl-bps       Create bp with corresponding git feature branch and short sha code. i.e., make create-dsl-bps DSL_BP=bastion_host_svm
create-dsl-endpoint  Create Endpoint Resource. i.e., make create-dsl-endpoint EP=bastion_host_svm
create-dsl-runbook   Create Runbook. i.e., make create-dsl-runbook RUNBOOK=update_ad_dns
create-helm-bps      Create single helm chart bp (with current git branch / tag latest in name). i.e., make create-helm-bps CHART=argocd
delete-all-helm-charts-apps Delete all helm chart apps (with current git branch / tag latest in name)
delete-all-helm-charts-bps Delete all helm chart blueprints (with current git branch / tag latest in name)
delete-all-helm-mp-items Remove all existing helm marketplace items for current git version. Easier to republish existing version. 
delete-dsl-apps      Delete Application that matches your git feature branch and short sha code. i.e., make delete-dsl-apps DSL_BP=bastion_host_svm
delete-dsl-bps       Delete Blueprint that matches your git feature branch and short sha code. i.e., make delete-dsl-bps DSL_BP=bastion_host_svm
delete-helm-apps     Delete single helm chart app (with current git branch / tag latest in name). i.e., make delete-helm-apps CHART=argocd
delete-helm-bps      Delete single helm chart blueprint (with current git branch / tag latest in name). i.e., make delete-helm-bps CHART=argocd
download-karbon-creds Leverage karbon krew/kubectl plugin to login and download config and ssh keys
fix-image-pull-secrets Add image pull secret to get around image download rate limiting issues
help                 Show this help
init-bastion-host-svm Initialize Karbon Admin Bastion Workstation and Endpoint. .i.e., make init-bastion-host-svm ENVIRONMENT=kalm-main-16-1
init-kalm-cluster    Initialize Karbon Cluster. i.e., make init-kalm-cluster ENVIRONMENT=kalm-main-16-1
launch-all-helm-charts Launch all helm chart blueprints with default test parameters (minus already deployed charts)
launch-dsl-bps       Launch Blueprint that matches your git feature branch and short sha code. i.e., make launch-dsl-bps DSL_BP=bastion_host_svm
launch-helm-bps      Launch single helm chart app (with current git branch / tag latest in name). i.e., make launch-helm-bps CHART=argocd
merge-kubectl-contexts Merge all K8s cluster kubeconfigs within path to config file.  Needed to support multiple clusters in future
print-secrets        Print variables including secrets. i.e., make print-secrets ENVIRONMENT={environment_folder_name}
print-vars           Print environment variables. i.e., make print-vars ENVIRONMENT={environment_folder_name}
publish-all-existing-helm-bps Publish New Version of all existing helm chart marketplace items with latest git release.
publish-all-new-helm-bps First Time Publish of ALL Helm Chart Blueprints into Marketplace
publish-existing-dsl-bps Publish Standard DSL BP of already existing. i.e., make publish-existing-dsl-bps DSL_BP=bastion_host_svm
publish-existing-helm-bps Publish Single Helm Chart of already existing Helm Chart. i.e., make publish-existing-helm-bps CHART=argocd
publish-new-dsl-bps  First Time Publish of Standard DSL BP. i.e., make publish-new-dsl-bps DSL_BP=bastion_host_svm
publish-new-helm-bps First Time Publish of Single Helm Chart. i.e., make publish-new-helm-bps CHART=argocd
run-all-dsl-runbook-scenarios Runs all dsl runbook scenarios for given runbook i.e., make run-all-dsl-runbook-scenarios RUNBOOK=update_ad_dns
run-dsl-runbook      Run Runbook with Specific Scenario. i.e., make run-dsl-runbook RUNBOOK=update_ad_dns SCENARIO=create_ingress_dns_params
unpublish-all-helm-bps Unpublish all Helm Chart Blueprints of latest git release (i.e., git tag --list)
unpublish-dsl-bps    UnPublish Standard DSL BP of already existing. i.e., make unpublish-dsl-bps DSL_BP=bastion_host_svm
unpublish-helm-bps   Unpublish Single Helm Chart Blueprint - latest git release. i.e., make unpublish-helm-bps CHART=argocd
```

1. All the tools needed to develop Calm DSL and interact with the target Kubernetes applications / Karbon environments are available within a local docker container.  If the image is unavailable, it will build it, run and attach to it interactively with the local directory `dsl-workspace` already mounted.  
    > Initiate Calm DSL docker container workspace by running `make docker-run ENVIRONMENT=kalm-main-{hpoc-id}`. For Example: `make docker-run`

1. Copy ./secrets.yaml.example and update all required values with a `required_secrets`. i.e., `artifactory_password: required_secret` should be changed to reflect correct password.
   Optionally set the `optional_secrets` for optional use cases - i.e., github_user and password for jenkins, azure/aws for cloud blueprints.

    ```bash
    cp ./secrets.yaml.example ./secrets.yaml
    vi ./secrets.yaml
    ```

1. Initialize Environment Configurations and Secrets. `Environment` value should be either `kalm-main-{hpoc_id}` or `kalm-develop-{hpoc_id}`.
    `hpoc-id` are last digits of HPOC Name. i.e., `PHX-SPOC011-2` is `kalm-main-11-2` and `PHX-SPOC005-2` `kalm-develop-5-2`

    ```bash
    $ ./init_local_configs.sh                                                                                                                                                                     ─╯
    Usage: ./init_local_configs.sh [~/.ssh/ssh-private-key] [~/.ssh/ssh-private-key.pub] [kalm-env-hpoc-id]
    Example: ./init_local_configs.sh .local/_common/nutanix_key .local/_common/nutanix_public_key kalm-main-10-1
    ```

1. [Optional] Most environment configs can be found within the `.local/[_common|kalm-main-{hpoc-id}]/` and `configs/[_common|kalm-main-{hpoc-id}]/]`.  All `default` environment configs are stored within the `config/_common/.env` file. If you need to override anything, update the environment specific folder to override. You can validate afterwards using `make print-vars`
  
    > See `./dot-env.example` for example ovverride of multiple vars for a multi-node hpoc cluster.

1. Always validate configs and secrets are set correctly via `make print-vars ENVIRONMENT=kalm-main-{hpoc-id}` and/or `make print-secrets ENVIRONMENT=kalm-main-{hpoc-id}`

    ```bash
    $ make print-vars ENVIRONMENT=kalm-main-19-4

    PE_CLUSTER_NAME=PHX-SPOC019-4
    KARBON_EXT_IPV4=10.38.19.212
    KARBON_INGRESS_VIP=10.38.19.213
    KARBON_LB_ADDRESSPOOL=10.38.19.213-10.38.19.214
    CIDR=26
    DNS=10.38.19.203
    GATEWAY=10.38.19.193
    KARBON_WORKER_COUNT=5
    NETWORK=10.38.19.192
    OBJECTS_STORE_PUBLIC_IP=10.38.19.210
    PC_IP_ADDRESS=10.38.19.201
    PE_CLUSTER_VIP=10.38.19.199
    PE_DATASERVICES_VIP=10.38.19.200
    ...
    ```

## Bootstrapping Calm Blueprints / Marketplace & Karbon `kalm-main-{hpoc-id}` Production Cluster

The following tasks will create/compile/launch all available runbooks, endpoints, DNS records, helm charts and blueprints required to stage environment (i.e., bastion host vm used as target linux endpoint for all underlying helm-chart blueprint deployments).
It will subsequently launch the deployment of the underlying Karbon `kalm-main-{hpoc-id}` production cluster along with key components such as `MetalLB`, `Cert-Manager` and `Ingress-Nginx`. `Kyverno` is also deployed (along with admission controller policies) to handle docker hub rate limiting causes issues.

> NOTE: The default Karbon kalm-main-{hpoc-id} includes 5 worker nodes to handle running all the helm charts simultaneously.

Generally speaking, this `Production-like` cluster can be used to serve multiple demonstration purposes, such as:

* Zero Downtime Upgrades during Karbon OS and Kubernetes Cluster Upgrades
* Ability for Karbon to host pseudo "centralized" services, such as:
  * multi-cluster management solutions (e.g., rancher, kasten, etc.) deployed by Calm
  * shared utility services (e.g., artifactory, harbor, grafana, argocd, etc.) deployed by Calm
* Horizontal Pod Autoscaling scenarios across nodes

### Boostrapping Option 1: Bootstrap `kalm-main-{hpoc-id}` Environment - Single Command

1. Provision Primary Calm and Karbon "Main" Environment using the following command:

  `make bootstrap-kalm-all ENVIRONMENT=kalm-main-{hpoc_id}`
  > For Example: `make bootstrap-kalm-all ENVIRONMENT=kalm-main-11-2`

### Boostrapping Option 2: Bootstrap `kalm-main-{hpoc-id}` Environment - Multi-Step

1. Create Bastion Host and Set IP for Downstream Runbooks
  
  `make init-bastion-host-svm ENVIRONMENT=kalm-main-{hpoc_id}`
  > For Example: `make init-bastion-host-svm ENVIRONMENT=kalm-main-11-2`

1. Initialize Calm Shared Infra for all dependent Endpoints, Runbooks and available helm chart Blueprints [found in `dsl/helm-charts/.`]. This task will also publish all the helm charts into Marketplace.

  `make init-shared-infra ENVIRONMENT=kalm-main-{hpoc_id}`
  > For Example: `make init-bastion-host-svm ENVIRONMENT=kalm-main-11-2`

1. Create `Karbon Cluster Deployment` blueprint and Publish to Marketplace using the following command:

  `make init-kalm-cluster ENVIRONMENT=kalm-main-{hpoc_id}`
  > For Example: `make init-kalm-cluster ENVIRONMENT=kalm-main-11-2`

## Nutanix Employees ONLY: See [Bootstrapping a Single-Node HPOC - Kalm Environment](docs/single-node-hpoc-bootstrap.md)