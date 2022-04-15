# Download Calm DSL latest from hub.docker.com
FROM ntnx/calm-dsl:latest

# Add gnu-make package so that it can execute make targets from docker container
RUN apk update \
    && apk upgrade \
    && apk add --no-cache make \
        git \
        yq \
        curl \
        openssl \
        gnupg \
        gpg

COPY ./scripts/bastion /tmp

WORKDIR /tmp

## install utils
RUN chmod +x *.sh \
  && ./install_helm.sh \
  && ./install_kubectl.sh

## import local gpg key
COPY ./.local/sops_gpg_key /tmp
WORKDIR /tmp
RUN gpg --import sops_gpg_key
