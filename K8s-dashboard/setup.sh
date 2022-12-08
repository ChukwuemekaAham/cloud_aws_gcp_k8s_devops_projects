#!/bin/bash

set -x

#Setup Env Vars

export DASHBOARD_VERSION="v2.6.0"

# Deploy the dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/aio/deploy/recommended.yaml

# Since this is deployed to our private cluster, we need to access it via a proxy.
# kube-proxy is available to proxy our requests to the dashboard service. 

kubectl proxy --port=8080 --address=0.0.0.0 --disable-filter=true &


#This will start the proxy, listen on port 8080, listen on all interfaces, 
#and will disable the filtering of non-localhost requests.
# This command will continue to run in the background of the current terminal’s session.

# disabled request filtering, a security feature that guards against XSRF attacks. 
# This isn’t recommended for a production environment, but is useful for dev environment.


