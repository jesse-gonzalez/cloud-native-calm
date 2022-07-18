


#### Connectivity Details

MongoDB OpsManager URL:

```bash
## Run via kubectl
OPSMANAGER_HOST=$(kubectl get svc mongodb-opsmanager-svc-ext -n mongodb-enterprise -o jsonpath="{.status.loadBalancer.ingress[].ip}")
OM_BASE_URL="http://opsmanager.${OPSMANAGER_HOST}.nip.io:8080"

echo $OPSMANAGER_HOST
echo $OM_BASE_URL
```

Login with `admin` and mongo_db_password, which can be found via:

`kubectl get secret om-admin-secret -o jsonpath='{.data.Password}' -n mongodb-enterprise | base64 -d && echo`

OpsManager API Keys for Deploying MongoDB AppDatabases:

```bash
## Run via kubectl
OPSMANAGER_API_USER=$(kubectl get secrets mongodb-enterprise-mongodb-opsmanager-admin-key -n mongodb-enterprise -o jsonpath='{.data.publicKey}' | base64 -d)
OPSMANAGER_API_KEY=$(kubectl get secrets mongodb-enterprise-mongodb-opsmanager-admin-key -n mongodb-enterprise -o jsonpath='{.data.privateKey}' | base64 -d)
OPSMANAGER_ORG_ID=$(curl --user ${opsmanager_api_user}:${opsmanager_api_key} --digest -s --request GET "${OPSMANAGER_HOST}:8080/api/public/v1.0/orgs?pretty=true" | jq -r '.results[].id')

echo $OPSMANAGER_API_USER
echo $OPSMANAGER_API_KEY
echo $OPSMANAGER_ORG_ID
```
