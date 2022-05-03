echo "** Install JQ..."
sudo yum install -y jq

jq -h

echo "** Install YQ..."
VERSION=v4.25.1
BINARY=yq_linux_amd64
sudo wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - |\
  sudo tar xz && sudo mv ${BINARY} /usr/bin/yq