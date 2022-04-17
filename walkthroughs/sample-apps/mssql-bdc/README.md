# Deploy MS SQL Big Data Cluster on Karbon

## Install AZDATA

## Customize Deployment

Things we can customize:

 - cluster name
 - prod vs. dev
 - endpoint ports
     - more than 1 sql big data cluster on K8s environment? - Dev Scenario?
     -
 - replicas / scale
 - storage
     - with or without spark?
     - hdfs replication vs. aos replication factor? Ray hassan
         - as low as possible, default = 3, lowest=2?
- Lessons Learned from Cloudera Hadoop / HDFS?
- Test Plan?
    - Goal: Load Dataset, determine storage footprint given replication factors
        - 1 TB of Data
        - Copy via HDFS 3x
        - Test with Custom Storage Container
        - Incrementally Disable Option and Determine Storage Footprint
    - Prod Config?
        - Dedicated Storage Container with All Options Enabled (i.e., EC-x, De-Dup, etc.). Min. 4+ nodes needed for Erasure Coding
        - All Flash/NVM with EC-X? Possible tuning option could be to threshold for frequency (i.e., 1 hr.)
        - AOS RF = 2
        -


### Built-In Templates

`azdata bdc config list`

### Create a copy of Existing Templates

`azdata bdc config init --source kubeadm-prod --target kalm-sqlbdc`

### Edit

VSO
    `azdata bdc config path or replace`

> Examples

```bash
azdata bdc config replace --config-file custom-bdc/bdc.json --json-values "metadata.name=test-cluster"
azdata bdc config replace --config-file custom-bdc/control.json --json-values "$.spec.endpoints[?(@.name==""Controller"")].port=30000"
azdata bdc config replace --config-file custom-bdc/bdc.json --json-values "$.spec.resources.storage-0.spec.replicas=10"
azdata bdc config replace --config-file custom-bdc/bdc.json --json-values "$.spec.resources.compute-0.spec.replicas=4"
azdata bdc config replace --config-file custom-bdc/bdc.json --json-values "$.spec.resources.data-0.spec.replicas=4"
```

## Deploy

pre-download sql binary

kubectl create deployment test --image=mcr.microsoft.com/mssql/bdc/mssql-app-service-proxy:2019-CU10-ubuntu-20.04 --replicas 5 -- -help

`azdata bdc create --config-profile kalm-sqlbdc --accept-eula yes`


## Connect

> Get List of endpoints

```bash
$ azdata bdc endpoint list -o table
Description                                             Endpoint                                                 Name               Protocol
------------------------------------------------------  -------------------------------------------------------  -----------------  ----------
Gateway to access HDFS files, Spark                     https://10.7.250.112:30443                               gateway            https
Spark Jobs Management and Monitoring Dashboard          https://10.7.250.112:30443/gateway/default/sparkhistory  spark-history      https
Spark Diagnostics and Monitoring Dashboard              https://10.7.250.112:30443/gateway/default/yarn          yarn-ui            https
Application Proxy                                       https://10.7.250.139:30778                               app-proxy          https
Management Proxy                                        https://10.7.250.112:30777                               mgmtproxy          https
Log Search Dashboard                                    https://10.7.250.112:30777/kibana                        logsui             https
Metrics Dashboard                                       https://10.7.250.112:30777/grafana                       metricsui          https
Cluster Management Service                              https://10.7.250.139:30080                               controller         https
SQL Server Master Instance Front-End                    10.7.250.112,31433                                       sql-server-master  tds
HDFS File System Proxy                                  https://10.7.250.112:30443/gateway/default/webhdfs/v1    webhdfs            https
Proxy for running Spark statements, jobs, applications  https://10.7.250.112:30443/gateway/default/livy/v1       livy               https
Hadoop KMS proxy for managing Hadoop Encryption keys    https://10.7.250.112:30443/gateway/default/hadoopkms/v1  hadoopkms          https
```


## Load Data

./bootstrap-sample-db.sh mssql-cluster 10.7.250.112 10.7.250.112
