#!/bin/bash

#
# Download kubectl, save kubeconfig, and ensure we can access the test cluster
#

set -e 

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

mkdir ${HOME}/.kube

# echo $KUBECONFIG_CONTENTS | base64 -D - > ${HOME}/.kube/config
# kubectl version

# gcloud stuff
# https://stackoverflow.com/questions/38762590/how-to-install-google-cloud-sdk-on-travis

if [ ! -d "${HOME}/google-cloud-sdk/bin" ]
then
    rm -rf $HOME/google-cloud-sdk
    export CLOUDSDK_CORE_DISABLE_PROMPTS=1
    curl https://sdk.cloud.google.com | bash
fi

# gcloud command
export PATH=${HOME}/google-cloud-sdk/bin:${PATH}

# ensure we have the gcloud binary
gcloud version

# get gcloud credentials
echo $FISSION_CI_SERVICE_ACCOUNT | base64 -d - > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

# get kube config
gcloud container clusters get-credentials fission-ci-1 --zone us-central1-a --project fission-ci

# remove gcloud creds
unset FISSION_CI_SERVICE_ACCOUNT
rm ${HOME}/gcloud-service-key.json

# does it work?

if [ ! -f ${HOME}/.kube/config ]
then
    echo "Missing kubeconfig"
    exit 1
fi

kubectl get node
