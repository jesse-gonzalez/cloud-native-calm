

#### Connectivity Details

Wildcard Domain URL:
[https://@@{instance_name}@@.@@{Helm_HashiCorpVault.wildcard_ingress_dns_fqdn}@@](https://@@{instance_name}@@.@@{Helm_HashiCorpVault.wildcard_ingress_dns_fqdn}@@)

NipIO Domain URL:
[https://@@{instance_name}@@.@@{Helm_HashiCorpVault.nipio_ingress_domain}@@](https://@@{instance_name}@@.@@{Helm_HashiCorpVault.nipio_ingress_domain}@@)

#### Login to Vault via kubectl

VAULT_TOKEN=$(kubectl exec -ti vault-0 -n vault -- grep 'Initial Root Token' /tmp/.vault-init | awk '{print $NF}')
kubectl exec -ti vault-0 -n vault -- vault login $VAULT_TOKEN

#### Login to Vault via vault cli

export VAULT_ADDR='https://vault.10.38.20.17.nip.io'
export VAULT_SKIP_VERIFY='true'
export VAULT_TOKEN=$(kubectl exec -n vault -ti pod/vault-0 -- grep 'Initial Root Token' /tmp/.vault-init | awk '{print $NF}')

vault login
vault status