#!/bin/bash

#####
## This script will populate the .local creds and underlying environment configs for target hpoc cluster

#####
## Pre-Reqs are that it's running within Calm DSL Utils Container and Secrets.yaml have already been updated

SSH_PRIVATE_KEY_PATH=$1
SSH_PUBLIC_KEY_PATH=$2
ENVIRONMENT=$3

TIMESTAMP=$(date +%s)

ARGS_LIST=($@)

## If not in docker container, exit.
if [ ! -f /.dockerenv ]; then
  echo "Must run from Calm DSL Utils Docker Container. Run 'make docker-run' first"
  exit
fi

if [ ${#ARGS_LIST[@]} -lt 3 ]; then
	echo 'Usage: ./init_local_configs.sh [~/.ssh/ssh-private-key] [~/.ssh/ssh-private-key.pub] [kalm-env-hpoc-id]'
	echo 'Example: ./init_local_configs.sh .local/_common/nutanix_key .local/_common/nutanix_public_key kalm-main-10-1'
	exit
fi

if [ ! -f ./secrets.yaml ]; then
  echo "./secrets.yaml doesn't exist, copy ./secrets.yaml.example and update accordingly"
  exit
fi

if [ ! -f $SSH_PRIVATE_KEY_PATH ]; then
  echo "$SSH_PRIVATE_KEY_PATH doesn't exist, validate that path is correct"
  exit
fi

if [ ! -f $SSH_PUBLIC_KEY_PATH ]; then
  echo "$SSH_PUBLIC_KEY_PATH doesn't exist, validate that path is correct"
  exit
fi


## parse_yaml helper function
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# parse yaml and get values
eval $(parse_yaml ./secrets.yaml)

# loop through each key and check value
echo "Validating secret values have no default values..."
for i in $(cat ./secrets.yaml | awk -F: '{print $1}')
do
  key_val=$(eval echo \$$i)
  if [ "$key_val" == "required_secret" ]; then
    echo "ERROR: The following REQUIRED key: '$i' still has a default value of 'required_secret' set in ./secrets.yaml. please update"
    exit
  fi
  if [ "$key_val" == "optional_secret" ]; then
    echo "INFO: The '$i' key still has 'optional_secret' set in ./secrets.yaml. Please re-run if needed."
  fi
done

echo "Initialize config/$ENVIRONMENT Directories if it doesn't exist"

if [ ! -d config/$ENVIRONMENT ]; then
	mkdir config/$ENVIRONMENT
fi

if [ ! -d .local/$ENVIRONMENT ]; then
	mkdir -p .local/$ENVIRONMENT
fi

echo "Copying ssh keys to .local/$ENVIRONMENT"

cat $SSH_PRIVATE_KEY_PATH >| .local/$ENVIRONMENT/nutanix_key
cat $SSH_PUBLIC_KEY_PATH >| .local/$ENVIRONMENT/nutanix_public_key

echo "Copying plaintext secrets.yaml to config/$ENVIRONMENT"

if [ -f config/$ENVIRONMENT/secrets.yaml ]; then
  echo "config/$ENVIRONMENT/secrets.yaml already exist, backing up and overwriting"
  mv config/$ENVIRONMENT/secrets.yaml config/$ENVIRONMENT/secrets-$TIMESTAMP.yaml
fi

cp ./secrets.yaml config/$ENVIRONMENT/secrets.yaml

echo "Generating and Exporting PGP Secret key needed to decode SOPS"

PGP_EMAIL="dsl-admin-$TIMESTAMP@no-reply.com"

# generate pgp key for Secrets

gpg --quiet --batch --generate-key <<EOF
%echo Generating a basic OpenPGP key for Yaml Secret
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: dsl-admin
Name-Comment: Used for DSL Secrets
Name-Email: $PGP_EMAIL
Expire-Date: 0
%no-ask-passphrase
%no-protection
%commit
%echo done
EOF

PGP_FINGERPRINT=$(gpg --list-key "$PGP_EMAIL" | head -n 2 | tail -n 1 | xargs)

if [ -f .local/$ENVIRONMENT/sops_gpg_key ]; then
  echo ".local/$ENVIRONMENT/sops_gpg_key already exist, backing up and overwriting"
  mv .local/$ENVIRONMENT/sops_gpg_key .local/$ENVIRONMENT/sops_gpg_key-$TIMESTAMP
fi

# exporting key
gpg --quiet --export-secret-key --armor "$PGP_EMAIL" > .local/$ENVIRONMENT/sops_gpg_key

echo "Setting fingerprint: $PGP_FINGERPRINT in file config/$ENVIRONMENT/.sops.yaml"

if [ -f config/$ENVIRONMENT/.sops.yaml ]; then
  echo "config/$ENVIRONMENT/.sops.yaml already exist, backing up and overwriting"
  mv config/$ENVIRONMENT/.sops.yaml config/$ENVIRONMENT/.sops-$TIMESTAMP.yaml
fi

cat <<EOF | tee config/$ENVIRONMENT/.sops.yaml
creation_rules:
    - pgp: '$(echo $PGP_FINGERPRINT)'
EOF

echo "Encrypting config/$ENVIRONMENT/secrets.yaml with fingerprint: $PGP_FINGERPRINT in file config/$ENVIRONMENT/.sops.yaml"

sops --encrypt --in-place --pgp $PGP_FINGERPRINT config/$ENVIRONMENT/secrets.yaml

# OVERRIDING YAML and PGP KEY PATH if _common sops_gpg_key is unavailable

echo "Setting config/$ENVIRONMENT/.env with Override Paths"

if [ -f config/$ENVIRONMENT/.env ]; then
  echo "config/$ENVIRONMENT/.env already exist, backing up and overwriting"
  mv config/$ENVIRONMENT/.env config/$ENVIRONMENT/.env-$TIMESTAMP
fi

echo "PGP_KEY_PATH = .local/$ENVIRONMENT/sops_gpg_key" >> config/$ENVIRONMENT/.env
echo "YAML_SECRETS_PATH = config/$ENVIRONMENT/secrets.yaml" >> config/$ENVIRONMENT/.env

read  -p "Would you like to delete plaintext ./secrets.yaml? (y or n): " delete_prompt

if [ "$delete_prompt" == "y" ]; then
  echo "Deleting ./secrets.yaml"
  rm ./secrets.yaml
elif [ "$delete_prompt" == "n" ]; then
  echo "Renaming ./secrets.yaml to ./secrets-$ENVIRONMENT-$TIMESTAMP.yaml"
  mv ./secrets.yaml ./secrets-$ENVIRONMENT-$TIMESTAMP.yaml
else
  echo "Invalid Entry. please type 'y' or 'n'."
  read -p "Would you like to delete manually created ./secrets.yaml? (y or n): " delete_prompt
fi

echo "SUCCESS: Decrypt secrets using following command 'sops --decrypt config/$ENVIRONMENT/secrets.yaml'"
