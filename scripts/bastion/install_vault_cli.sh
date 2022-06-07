VERSION=1.10.3

wget -O "/tmp/vault_${VERSION}_linux_amd64.zip" "https://releases.hashicorp.com/vault/${VERSION}/vault_${VERSION}_linux_amd64.zip" 
unzip "/tmp/vault_${VERSION}_linux_amd64.zip"
mv vault /usr/local/bin/vault
chmod +x /usr/local/bin/vault

rm "/tmp/vault_${VERSION}_linux_amd64.zip"

vault --help