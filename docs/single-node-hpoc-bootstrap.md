# Bootstrapping a SingleNode HPOC - Kalm Environment

The HPOC bootstrapping process assumes that the server was built using the following networking scheme

## Quick Start - Single Node HPOC Cluster ONLY

> Pre-Requisites: Reserve Single Node HPOC Cluster using instructions below: [Staging Initial HPOC, Karbon and Calm Cluster](#staging-initial-hpoc-karbon-and-calm-cluster)

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


## Staging Initial HPOC, Karbon and Calm Cluster

1. Navigate to `https://rx.corp.nutanix.com/` hpoc reservation site and reserve cluster a single node hpoc (i.e., PHX-SPOC011-2) cluster.  This process takes roughly 3 hours to complete, but can be reserved on-demand or scheduled in advance.

    > `TIP 1`: During your reservation, set password to something you're familiar with as to avoid having to update creds within `.local\<environment>` path
        ![rx-cluster-pass](images/rx-cluster-pass.png)

    > `TIP 2`: Select the `Custom Workloads` option, and select the following options to ensure that you can start with a baseline deplyment of Objects, Calm, Karbon and Files:
        - `Core: Run LCM Updates & Upload OS Images`
        - `Files: Create File Server` - Needed for NFS Exports / ReadWriteMany PV Scenarios
        - `Calm`
        - `Karbon`
        - `Objects: Create Object Store` - Needed for Kasten Scenarios.
        ![rx-custom-workloads-option](images/rx-custom-workloads-option.png)

## Bootstrapping Calm Blueprints / Marketplace & Karbon `kalm-main-{hpoc-id}` Cluster

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

## Outstanding Manual Procedures

1. [Optional] - Configure Project `Environment` tab (e.g., credentials, vcpu, memory, image, etc.) to ensure that Launching of Marketplace Items are successful.

    ![project-environment](docs/images/project-environment.png)

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
