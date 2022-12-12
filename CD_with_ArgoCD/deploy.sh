#!/bin/bash

set -x

# Connect with ArgoCD CLI using our cluster context:

# CONTEXT_NAME=`kubectl config view -o jsonpath='{.current-context}'`
# argocd cluster add $CONTEXT_NAME

# admin@eks-eksctl-demo.us-east-1.eksctl.io

GITHUB_USERNAME=ChukwuemekaAham
kubectl create namespace ecsdemo-nodejs
argocd app create ecsdemo-nodejs \
    --repo https://github.com/$GITHUB_USERNAME/ecsdemo-nodejs.git  \
    --path kubernetes --dest-server https://kubernetes.default.svc \
    --dest-namespace ecsdemo-nodejs


#Application is now setup, let’s have a look at the deployed application state:

argocd app get ecsdemo-nodejs


# We can see that the application is in an OutOfSync status since the application 
# has not been deployed yet. We are now going to sync our application:

argocd app sync ecsdemo-nodejs