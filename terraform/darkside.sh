sudo cp cert/ca.crt /etc/pki/ca-trust/source/anchors/ca.crt
sudo update-ca-trust

sudo chown -R cloud-user /opt/ocp-darkside/mirror

sudo /opt/ocp-darkside/mirror-registry/mirror-registry install --quayHostname $(hostname) --sslCert ~/cert/cert.crt --sslKey ~/cert/cert.key --initUser nutanix --initPassword 'nutanix/4u' --verbose
echo '{"auths":{"'$(hostname)':8443": {"auth": "'$(echo -n 'nutanix':'nutanix/4u' | base64 -w0 )'","email": "you@example.com"}}}' > ps.json

export LOCAL_SECRET_JSON=./ps.json
export REMOVABLE_MEDIA_PATH=/opt/ocp-darkside/mirror
export LOCAL_REGISTRY=$(hostname)':8443' 
export LOCAL_REPOSITORY='ocp4/openshift4'

oc image mirror -a ${LOCAL_SECRET_JSON} --from-dir=${REMOVABLE_MEDIA_PATH} "file://openshift/release:4.11.0-0.nightly-2022-05-20-213928*" ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}
