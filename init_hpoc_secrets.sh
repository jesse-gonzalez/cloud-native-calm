#!/usr/bin/env bash

#####
## This script will populate the .local creds and underlying environment configs for target hpoc cluster

SSH_PRIVATE_KEY_PATH=$1
SSH_PUBLIC_KEY_PATH=$2
ENVIRONMENT=$3
HPOC_CLUSTER_PASS=$4

## values below are set based on inputs provided
ARTIFACTORY_USER="admin"
ARTIFACTORY_PASS=$HPOC_CLUSTER_PASS
AWX_USER="admin"
AWX_PASS=$HPOC_CLUSTER_PASS
JENKINS_USER="admin"
JENKINS_PASS=$HPOC_CLUSTER_PASS
ARGOCD_USER="admin"
ARGOCD_PASS=$HPOC_CLUSTER_PASS
KEYCLOAK_USER="admin"
KEYCLOAK_PASS=$HPOC_CLUSTER_PASS
HARBOR_USER="admin"
HARBOR_PASS=$HPOC_CLUSTER_PASS
RANCHER_USER="admin"
RANCHER_PASS=$HPOC_CLUSTER_PASS
CALM_DSL_USER="admin"
CALM_DSL_PASS=$HPOC_CLUSTER_PASS
NUTANIX_KEY_USER="nutanix"
NUTANIX_USER="nutanix"
NUTANIX_PASS="nutanix/4u"
PRISM_CENTRAL_USER="admin"
PRISM_CENTRAL_PASS=$HPOC_CLUSTER_PASS
PRISM_ELEMENT_USER="admin"
PRISM_ELEMENT_PASS=$HPOC_CLUSTER_PASS
WINDOWS_DOMAIN_ADMIN="Administrator@ntnxlab.local"
WINDOWS_DOMAIN_PASS="nutanix/4u"
NUTANIX_PRIVATE_KEY_PATH=$SSH_PRIVATE_KEY_PATH
NUTANIX_PUB_KEY_PATH=$SSH_PUBLIC_KEY_PATH

ARGS_LIST=($@)

## If not in docker container, exit.
if [ ! -f /.dockerenv ]; then
  echo "Must run from Calm DSL Utils Docker Container. Run 'make docker-run' first"
  exit
fi

if [ ${#ARGS_LIST[@]} -lt 4 ]; then
	echo 'Usage: ./init_hpoc_secrets.sh [~/.ssh/ssh-private-key] [~/.ssh/ssh-private-key.pub] [kalm-env-hpoc-id] [hpoc-global-pass]'
	echo 'Example: ./init_hpoc_secrets.sh .local/_common/nutanix_key .local/_common/nutanix_public_key kalm-main-10-1 ntnxTech/4u!'
	exit
fi

echo "Initialize config/$ENVIRONMENT Directory if it doesn't exist"

if [ ! -d config/$ENVIRONMENT ]; then
	mkdir config/$ENVIRONMENT
  touch config/$ENVIRONMENT/.env
fi

echo "Updating .local secrets and environment specific configs"

if [ ! -d .local/$ENVIRONMENT ]; then
	mkdir -p .local/$ENVIRONMENT
fi

cat $NUTANIX_PRIVATE_KEY_PATH >| .local/$ENVIRONMENT/nutanix_key
cat $NUTANIX_PUB_KEY_PATH >| .local/$ENVIRONMENT/nutanix_public_key

cat <<EOF | tee config/$ENVIRONMENT/secrets.yaml
artifactory_user: $(echo $ARTIFACTORY_USER)
artifactory_password: $(echo $ARTIFACTORY_PASS)
awx_user: $(echo $AWX_USER)
awx_password: $(echo $AWX_PASS)
jenkins_user: $(echo $JENKINS_USER)
jenkins_password: $(echo $JENKINS_PASS)
argocd_user: $(echo $ARGOCD_USER)
argocd_password: $(echo $ARGOCD_PASS)
keycloak_user: $(echo $KEYCLOAK_USER)
keycloak_password: $(echo $KEYCLOAK_PASS)
harbor_user: $(echo $HARBOR_USER)
harbor_password: $(echo $HARBOR_PASS)
rancher_user: $(echo $RANCHER_USER)
rancher_password: $(echo $RANCHER_PASS)
calm_dsl_user: $(echo $CALM_DSL_USER)
calm_dsl_pass: $(echo $CALM_DSL_PASS)
nutanix_key_user: $(echo $NUTANIX_KEY_USER)
nutanix_user: $(echo $NUTANIX_USER)
nutanix_password: $(echo $NUTANIX_PASS)
prism_central_user: $(echo $PRISM_CENTRAL_USER)
prism_central_password: $(echo $PRISM_CENTRAL_PASS)
prism_element_user: $(echo $PRISM_ELEMENT_USER)
prism_element_password: $(echo $PRISM_ELEMENT_PASS)
windows_domain_user: $(echo $WINDOWS_DOMAIN_ADMIN)
windows_domain_password: $(echo $WINDOWS_DOMAIN_PASS)
EOF

echo "Generating PGP key for SOPS Secrets"

PGP_EMAIL="sops-pgp-$RANDOM@email.com"

# generate pgp key for Secrets

gpg --batch --generate-key <<EOF
%echo Generating a basic OpenPGP key for Yaml Secret
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: SOPS PGP Secret
Name-Comment: Used for DSL Secrets
Name-Email: $PGP_EMAIL
Expire-Date: 0
%no-ask-passphrase
%no-protection
%commit
%echo done
EOF

GPG_FINGERPRINT=$(gpg --list-key "$PGP_EMAIL" | head -n 2 | tail -n 1 | xargs)

cat <<EOF | tee config/$ENVIRONMENT/.sops.yaml
creation_rules:
    - pgp: '$(echo $GPG_FINGERPRINT)'
EOF

gpg --export-secret-key --armor "$PGP_EMAIL" > .local/$ENVIRONMENT/sops_gpg_key

sops --encrypt --in-place --pgp $GPG_FINGERPRINT config/$ENVIRONMENT/secrets.yaml

# OVERRIDING YAML and PGP KEY PATH if _common sops_gpg_key is unavailable

echo -n "PGP_KEY_PATH=.local/$ENVIRONMENT/sops_gpg_key" >> config/$ENVIRONMENT/.env
echo -n "YAML_SECRETS_PATH=config/$ENVIRONMENT/secrets.yaml" >> config/$ENVIRONMENT/.env

## sops --decrypt .local/$ENVIRONMENT/secrets.yaml
