# Bootstrapping a SingleNode HPOC - Kalm Environment

The HPOC bootstrapping process assumes that the server was built using the following networking scheme

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


## Staging Initial HPOC, Karbon and Calm Cluster

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