# Karbon and Calm (aka KALM) DSL Demo

This repo was built after the SA team had issues with our shared cluster being used for demonstrations and I had to cancel an important customer meeting in response.

In any case, as I was porting things to some interim cluster, I realized that this will most likely not be the last time that this will happen, so in light of being a considerate `infrastructure as code` citizen, I decided to treat the demo lab more like a "cattle" environment versus a "pet".

## Pre-Requisites

- docker
- git
- make

## Quick Start - Single Node HPOC Cluster ONLY

> Pre-Requisites: Reserve Single Node HPOC Cluster using instructions below: [Bootstrapping a SingleNode HPOC - Kalm Environment](#bootstrapping-a-singlenode-hpoc---kalm-environment)

1. Clone repo and change directory (cd):

    ```bash
    git clone https://github.com/jesse-gonzalez/cloud-native-calm.git && \
    cd cloud-native-calm
    ```

1. Exec in Docker Utils Container. If container image is unavailable, it will build locally.

    ```bash
    make docker-run
    ```

1. Copy ./secrets.yaml.example and update all required values with a `required_secrets`. i.e., `artifactory_password: required_secret` should be changed to reflect correct password.
   Optionally set the `optional_secrets` for optional use cases - i.e., github_user and password for jenkins, azure/aws for cloud blueprints.

    ```bash
    cp ./secrets.yaml.example ./secrets.yaml
    vi ./secrets.yaml
    ```

1. Initialize Environment Configurations and Secrets. `Environment` value should be either `kalm-main-{hpoc_id}` or `kalm-develop-{hpoc_id}`.
    `hpoc-id` are last 4 characters of HPOC Name. i.e., `PHX-SPOC011-2` is `kalm-main-11-2` or `kalm-develop-11-2`

    ```bash
    $ ./init_local_configs.sh                                                                                                                                                                     ─╯
    Usage: ./init_local_configs.sh [~/.ssh/ssh-private-key] [~/.ssh/ssh-private-key.pub] [kalm-env-hpoc-id]
    Example: ./init_local_configs.sh .local/_common/nutanix_key .local/_common/nutanix_public_key kalm-main-10-1
    ```

1. Bootstrap Nutanix Calm & Karbon `Production` (i.e., `kalm-main-{hpoc_id}`) Infratructure. [Additional Details](#bootstrapping-calm-blueprints--marketplace--karbon-kalm-main-hpoc-id-cluster)

    `make bootstrap-kalm-all ENVIRONMENT=kalm-main-{hpoc_id}`
    > EXAMPLE: `make bootstrap-kalm-all ENVIRONMENT=kalm-main-11-2`

1. [Optional] Launch all available helm chart blueprints into `Production` (i.e., `kalm-main-{hpoc_id}`) cluster

    `make launch-all-helm-charts ENVIRONMENT=kalm-main-{hpoc_id}`
    > EXAMPLE: `make launch-all-helm-charts ENVIRONMENT=kalm-main-11-2`

1. [Optional] Repeat step 2 & 3 in separate terminal window and Bootstrap Nutanix Calm & Karbon `Development` (i.e., `kalm-develop-{hpoc_id}`) Cluster

    `make init-kalm-cluster ENVIRONMENT=kalm-develop-{hpoc_id}`
    > EXAMPLE: `make init-kalm-cluster ENVIRONMENT=kalm-develop-11-2`

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


## Bootstrapping a SingleNode HPOC - Kalm Environment

The HPOC bootstrapping process assumes that the server was built using the following networking scheme

### Staging Initial HPOC, Karbon and Calm Cluster

1. Navigate to `https://rx.corp.nutanix.com/` hpoc reservation site and reserve cluster a single node hpoc (i.e., PHX-SPOC011-2) cluster.  This process takes roughly 3 hours to complete, but can be reserved on-demand or scheduled in advance.

    > `TIP 1`: During your reservation, set password to something you're familiar with as to avoid having to update creds within `.local\<environment>` path
        ![rx-cluster-pass](docs/images/rx-cluster-pass.png)

    > `TIP 2`: Select the `Custom Workloads` option, and select the following options to ensure that you can start with a baseline deplyment of Objects, Calm, Karbon and Files:
        - `Core: Run LCM Updates & Upload OS Images`
        - `Files: Create File Server` - Needed for NFS Exports / ReadWriteMany PV Scenarios
        - `Calm`
        - `Karbon`
        - `Objects: Create Object Store` - Needed for Kasten Scenarios.
        ![rx-custom-workloads-option](docs/images/rx-custom-workloads-option.png)

## Bootstrapping Local Development Environment

1. Clone repo and change directory (cd):
    `git clone https://github.com/nutanix-enterprise/shared-demo-karbon-calm.git` && `cd shared-demo-karbon-calm`

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

## Bootstrapping Calm Blueprints / Marketplace & Karbon `kalm-main-{hpoc-id}` Cluster

The following tasks will create/compile/launch all available runbooks, endpoints, DNS records, helm charts and blueprints required to stage environment (i.e., bastion host vm used as target linux endpoint for all underlying helm-chart blueprint deployments).
It will subsequently launch the deployment of the underlying Karbon `kalm-main-{hpoc-id}` production cluster along with key components such as `MetalLB`, `Cert-Manager` and `Ingress-Nginx`.  
`Kyverno` is also deployed (along with admission controller policies) to handle docker hub rate limiting causes issues.

> NOTE: The default Karbon kalm-main-{hpoc-id} includes 5 worker nodes to handle running all the helm charts simultaneously.

Generally speaking, this cluster can be used to serve multiple demonstration purposes, listed below.

- Zero Downtime Upgrades during Karbon OS and Kubernetes Cluster Upgrades
- Ability for Karbon to host pseudo "centralized" services, such as:
  - multi-cluster management solutions (e.g., rancher, kasten, etc.) deployed by Calm
  - shared utility services (e.g., artifactory, harbor, grafana, argocd, etc.) deployed by Calm
- Horizontal Pod Autoscaling scenarios across nodes

1. All the tools needed to run Calm DSL run are available within a local development container that will automount the local directory into the `dsl-workspace` directory.  Initiate Calm DSL docker container workspace by running `make docker-run ENVIRONMENT=kalm-main-{hpoc-id}`
    > For Example: `make docker-run`

1. Copy ./secrets.yaml.example and update all required values with a `required_secrets`. i.e., `artifactory_password: required_secret` should be changed to reflect correct password.
   Optionally set the `optional_secrets` for optional use cases - i.e., github_user and password for jenkins, azure/aws for cloud blueprints.

    ```bash
    cp ./secrets.yaml.example ./secrets.yaml
    vi ./secrets.yaml
    ```

1. Initialize Environment Configurations and Secrets. `Environment` value should be either `kalm-main-{hpoc_id}` or `kalm-develop-{hpoc_id}`.
    `hpoc-id` are last 4 characters of HPOC Name. i.e., `PHX-SPOC011-2` is `kalm-main-11-2` or `kalm-develop-11-2`

    ```bash
    $ ./init_local_configs.sh                                                                                                                                                                     ─╯
    Usage: ./init_local_configs.sh [~/.ssh/ssh-private-key] [~/.ssh/ssh-private-key.pub] [kalm-env-hpoc-id]
    Example: ./init_local_configs.sh .local/_common/nutanix_key .local/_common/nutanix_public_key kalm-main-10-1
    ```

#### Boostrapping Option 1: Bootstrap `kalm-main-{hpoc-id}` Environment - Single Command

1. Provision Primary Calm and Karbon "Main" Environment using the following command:

  `make bootstrap-kalm-all ENVIRONMENT=kalm-main-{hpoc_id}`
  > For Example: `make bootstrap-kalm-all ENVIRONMENT=kalm-main-11-2`

#### Boostrapping Option 2: Bootstrap `kalm-main-{hpoc-id}` Environment - Multi-Step

1. Create Bastion Host and Set IP for Downstream Runbooks
  
  `make init-bastion-host-svm ENVIRONMENT=kalm-main-{hpoc_id}`
  > For Example: `make init-bastion-host-svm ENVIRONMENT=kalm-main-11-2`

1. Initialize Calm Shared Infra for all dependent Endpoints, Runbooks and available helm chart Blueprints [found in `dsl/helm-charts/.`]. This task will also publish all the helm charts into Marketplace.

  `make init-shared-infra ENVIRONMENT=kalm-main-{hpoc_id}`
  > For Example: `make init-bastion-host-svm ENVIRONMENT=kalm-main-11-2`

1. Create `Karbon Cluster Deployment` blueprint and Publish to Marketplace using the following command:

  `make init-kalm-cluster ENVIRONMENT=kalm-main-{hpoc_id}`
  > For Example: `make init-kalm-cluster ENVIRONMENT=kalm-main-11-2`

## Outstanding Manual Procedures

1. [Optional] - Configure Project `Environment` tab (e.g., credentials, vcpu, memory, image, etc.) to ensure that Launching of Marketplace Items are successful.

    ![project-environment](docs/images/project-environment.png)

## CONTRIBUTING

Standard CICD / Git Common Workflow for Updating Repository

![config-as-code](docs/images/config-as-code.png)

### Local Development Testing

1. Create Issue via Github, and if owning change - Update Owner and Label Metadata - [Managing labels](https://docs.github.com/en/github/managing-your-work-on-github/managing-labels)

1. Create Git Branch on Local Machine:
 `git checkout -b <branch-name>`
    > TIP: branch names should be prefixed with either `feat`, `bug` or `task` label, issue number and meaningful branch name to simplify tracking, i.e., `[feat|bug|task}-{issue-num}-{branch-name}`. For Example: `feat-101-traefik`,`bug-102-failed_regex`,`task-103-newroute`

1. Make changes to code locally, test against environment using `Makefile` targets
    > `ENVIRONMENT` is representative of the name of config folder
    1. Initialize CALM DSL Docker Container by running `make init-dsl-config ENVIRONMENT=kalm-main-{hpoc-id}`
    > For Example: `make init-dsl-config ENVIRONMENT=kalm-demo-16-2`
    1. Create DSL blueprint by running `make create-dsl-bps DSL_BP=<blueprint_name>`.
    > For Example: `make create-dsl-bps DSL_BP=karbon_cluster_deployment`
    1. Launch blueprint `make launch-dsl-bps DSL_BP=<blueprint_name>` using default test parameters found in `dsl/{blueprint_name}/tests/test_default_params.py`
    > For Example: `make create-dsl-bps DSL_BP=karbon_cluster_deployment`

1. Alternative, if working on helm chart blueprints
    1. Create HELM CHART DSL blueprint by running `make create-helm-bps CHART=<chart_name>`.
    > For Example: `make create-helm-bps CHART=kasten`
    1. Launch blueprint `make launch-helm-bps CHART=<chart_name>` using default test parameters found in `dsl/helm_charts/{chart_name}/tests/test_default_params.py`
    > For Example: `make launch-helm-bps CHART=kasten`

1. Make Code Updates and Frequently Commit changes
 `git add .`
 `git commit -am "fix: commit message"`

### Push Local Changes to Remote Repository

Now that you've completed your local development and testing, push up changes remotely and initiate a Pull Request from Feature Branch so that your code can be approved and merged into the main/master branch.

1. Push up changes to remote repository
`git push origin --set-upstream <branch-name>`

1. Pull Down Latest and Greatest from Main Branch to Resolve Trivial/Non-Trivial Conflicts
 `git pull origin main --rebase`

1. Initiate a Pull Request from Github Remote URL by clicking on `Compare & Pull Request` option. - https://github.com/nutanix-enterprise/shared-demo-karbon-calm

1. Upon Code Review from Peer - `Merge Pull Request` and `Delete Feature Branch`.

### Create Final Blueprint and Release/Publish to Marketplace

Now that you've got your latest changes into the `main/master` branch. Let's create our master blueprints and push into marketplace.

1. Checkout local `main` branch and pull down latest
    `git checkout main && git pull origin main`
1. Run `git rev-parse --short HEAD` to get short sha code from commit id (i.e., `e986938`).
1. Run `git tag --list` to get the last version released. (i.e, `v1.0.1-239d543`)
1. Increment Latest Version and tag `git tag v1.0.x-{short-sha-code}`.
    > For Example: `git tag v1.0.2-e986938`
1. Push local tag to remote rep - `git push origin --tags`
1. Create Master Blueprints and Publish Existing to Marketplace, using the following command:
    `make create-master-bps publish-existing-master-bps DSL_BP=karbon_cluster_deployment`
1. Create All Helm Chart Blueprints and Publish Existing to Marketplace, using the following command:
    `make create-all-helm-master-bps publish-all-existing-helm-bps`
1. `IF WORKING ON NEW HELM BP - OPTION B`. Create Single Helm Chart Blueprints and Publish New to Marketplace, using the following command:
    `make create-helm-master-bps publish-new-helm-bps CHART=<chart-name>`
1. `IF WORKING ON EXISTING HELM BP - OPTION B`. Create Single Helm Chart Blueprints and Publish Existing to Marketplace, using the following command:
    `make create-helm-master-bps publish-existing-helm-bps CHART=<chart-name>`

## Manual Staging of Additional Nutanix Services

### Configure Nutanix Files NFS (RWX Scenarios)

1. Enable Files Service via Prism Central for easier navigation between demo environments
1. Configure NFS Protocol / Export to be leveraged by Karbon
    ![enable-nfs-protocol](docs/images/enable-nfs-protocol.png)
1. Configure NFS Export with Whitelist for Subnet

### Configure Nutanix Objects (Kasten.IO Scenarios)

1. Configure Access Keys
1. Configure Bucket
1. Configure Access Permission

## Defining Custom Environment Configurations

Most environment configs are stored within the `.local` and `configs`

### Update environment specific folder to override anything needed

> For Example, Override Number of Default Karbon Workers needed for `Production-like` cluster by adding `KARBON_WORKER_COUNT=1` into `configs\kalm-main-{hpoc-id}\.env`)