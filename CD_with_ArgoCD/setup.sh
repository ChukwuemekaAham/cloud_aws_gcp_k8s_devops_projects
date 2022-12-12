#!/bin/bash

set -x


kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml

#Install Argo CD CLI
#To interact with the API Server we need to deploy the CLI:

curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.7/argocd-linux-amd64

sudo chmod +x /usr/local/bin/argocd