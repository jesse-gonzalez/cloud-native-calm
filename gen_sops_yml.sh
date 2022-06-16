
# generate pgp key for Secrets

# 1. https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key 
# Must have user id and email
# 2. https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account
# 3. https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key


GITHUB_USER_ID="jesse-gonzalez"
GITHUB_EMAIL_ADDRESS="jesse.gonzalez@nutanix.com"

ENVIRONMENT=$1
GPG_USER_ID="jesse-gonzalez"
GPG_EMAIL_ADDRESS="jesse.gonzalez@nutanix.com"

gpg --batch --generate-key <<EOF
%echo Generating a basic OpenPGP key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $GPG_USER_ID
Name-Email: $GPG_EMAIL_ADDRESS
Expire-Date: 0
%no-ask-passphrase
%no-protection
%commit
%echo done
EOF

GPG_KEY_ID=$(gpg --list-key --keyid-format=long ${GPG_USER_ID} | grep pub | cut -d/ -f2 | cut -d ' ' -f1)

git config --global user.signingkey $GPG_KEY_ID

echo "Add the following key to Github. https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account"
gpg --armor --export $GPG_KEY_ID

#gpg --export-secret-key --armor "$PGP_EMAIL" > .local/$ENVIRONMENT/sops_gpg_key

