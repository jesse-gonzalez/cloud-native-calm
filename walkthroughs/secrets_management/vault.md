# Vault Walkthrough

Assumes Vault Helm Chart Install has been deployed via Calm

## unseal vault and validate status

```bash
UNSEAL1=$(kubectl exec -n vault -ti pod/vault-0 -- grep 'Unseal Key 1' /tmp/.vault-init | awk '{print $NF}')
UNSEAL2=$(kubectl exec -n vault -ti pod/vault-0 -- grep 'Unseal Key 2' /tmp/.vault-init | awk '{print $NF}')
UNSEAL3=$(kubectl exec -n vault -ti pod/vault-0 -- grep 'Unseal Key 3' /tmp/.vault-init | awk '{print $NF}')

for k in $UNSEAL1 $UNSEAL2 $UNSEAL3; do kubectl exec -n vault -ti pod/vault-0 -- vault operator unseal $k; done
```

## check vault status

`for k in {0..4}; do kubectl exec -n vault -ti pod/vault-$k -- vault status; done`

## check raft peer stats

ACTIVE_VAULT_POD=$(kubectl get pod -n vault -o name -l vault-active=true)
kubectl exec -n vault -ti $ACTIVE_VAULT_POD -- vault operator raft list-peers

## validate login

INITIAL_ROOT_TOKEN=$(kubectl exec -n vault -ti pod/vault-0 -- grep 'Initial Root Token' /tmp/.vault-init | awk '{print $NF}')
kubectl exec -n vault -ti pod/vault-0 -- vault login $INITIAL_ROOT_TOKEN

## simple test and validate

export VAULT_ADDR='https://vault.10.38.20.17.nip.io'
export VAULT_SKIP_VERIFY='true'
export VAULT_TOKEN=$(kubectl exec -n vault -ti pod/vault-0 -- grep 'Initial Root Token' /tmp/.vault-init | awk '{print $NF}')

vault login
vault status

vault secrets enable -path=secret/ kv
vault kv put secret/hello foo=world excited=yes
vault kv get secret/hello
vault kv get -format=json secret/hello | jq -r .data.excited
vault kv get -field=excited secret/hello
vault kv get -field=excited secret/hello
vault secrets enable -path=kv kv
vault secrets list

## import all secrets currently in common secrets.yaml

export VAULT_ADDR='https://vault.10.38.20.17.nip.io'
export VAULT_SKIP_VERIFY='true'
export VAULT_TOKEN=$(kubectl exec -n vault -ti pod/vault-0 -- grep 'Initial Root Token' /tmp/.vault-init | awk '{print $NF}')

vault login
vault status

vault secrets enable -path=nutanix/ kv-v2
vault secrets list

YAML=$(helm secrets view config/common/secrets.yaml | yq eval -o json)
vault kv put nutanix/calm -<<EOF
  $YAML
EOF

vault kv get nutanix/calm
