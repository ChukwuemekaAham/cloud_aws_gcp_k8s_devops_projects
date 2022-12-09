#!/bin/bash

set -x

# First, install the Flux Custom Resource Definition:

kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/master/deploy/crds.yaml

# Check that Helm is installed.
helm list

#In the following steps, the Git user name will be required. Without this information, 
# the resulting pipeline will not function as expected. Set this as an environment 
# variable to reuse in the next commands:

YOURUSER="ChukwuemekaAham"

#Create the flux Kubernetes namespace
kubectl create namespace flux

#add the Flux chart repository to Helm and install Flux.
#Update the Git URL below to match your user name and Kubernetes configuration manifest repository.

helm repo add fluxcd https://charts.fluxcd.io

helm upgrade -i flux fluxcd/flux \
--set git.url=git@github.com:${YOURUSER}/k8s-config \
--set git.branch=main \
--namespace flux

helm upgrade -i helm-operator fluxcd/helm-operator \
--set helm.versions=v3 \
--set git.ssh.secretName=flux-git-deploy \
--set git.branch=main \
--namespace flux

#Watch the install and confirm everything starts. There should be 3 pods.
kubectl get pods -n flux

#NOTES:
# Get the Git deploy key by either (a) running
# kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2

#or by (b) installing fluxctl through:

#Install fluxctl in order to get the SSH key to allow GitHub write access. 
# This allows Flux to keep the configuration in GitHub in sync with the 
# configuration deployed in the cluster.

# wget -O /usr/bin/fluxctl $(curl https://api.github.com/repos/fluxcd/flux/releases/latest | jq -r ".assets[] | select(.name | test(\"linux_amd64\")) | .browser_download_url")

# chmod 755 /usr/bin/fluxctl

# fluxctl version
# fluxctl identity --k8s-fwd-ns flux

# Copy the provided key and add that as a deploy key in the GitHub repository.