#!/bin/bash

set -x

export KARPENTER_VERSION=v0.19.3

helm repo add karpenter https://charts.karpenter.sh/
# "karpenter" has been added to your repositories

helm repo update
# ...Successfully got an update from the "karpenter" chart repository
# Update Complete. ⎈Happy Helming!⎈

# Install the chart passing in the cluster details and the Karpenter role ARN.

helm upgrade --install --namespace karpenter --create-namespace \
  karpenter karpenter/karpenter \
  --version ${KARPENTER_VERSION} \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=${KARPENTER_IAM_ROLE_ARN} \
  --set clusterName=${CLUSTER_NAME} \
  --set clusterEndpoint=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output json) \
  --set defaultProvisioner.create=false \
  --set aws.defaultInstanceProfile=KarpenterNodeInstanceProfile-${CLUSTER_NAME} \
  --wait # for the defaulting webhook to install before creating a Provisioner

# The command above:
# uses the CLUSTER_NAME so that Karpenter controller can contact the Cluster API Server.
# Karpenter configuration is provided through a Custom Resource Definition. We will be learning about providers in the next section, the --wait notifies the webhook controller to wait until the Provisioner CRD has been deployed.
# output:
# NAME: karpenterLAST DEPLOYED: Mon Dec  5 17:13:38 2022
# NAMESPACE: karpenter
# STATUS: deployed
# REVISION: 1
# TEST SUITE: None


# To check Karpenter is running you can check the Pods, Deployment and Service are Running.
kubectl get all -n karpenter

#To check the deployment. There should be one deployment karpenter
kubectl get deployment -n karpenter

# NAME        READY   UP-TO-DATE   AVAILABLE   AGE
# karpenter   2/2     2            2           2m6s

# To check running pods run the command below. There should be at least two pods, 
# each having two containers controller and webhook

kubectl get pods --namespace karpenter

# NAME                         READY   STATUS    RESTARTS   AGE
# karpenter-65c8cd57c9-9xx2l   2/2     Running   0          2m50s
# karpenter-65c8cd57c9-hfnk5   2/2     Running   0          2m50s

# To check containers controller and webhook, describe pod using following command

kubectl get pod -n karpenter --no-headers | awk '{print $1}' | head -n 1 | xargs kubectl describe pod -n karpenter

# We can increase the number of Karpenter replicas in the deployment for resilience. 
# Karpenter will elect a leader controller that is in charge of running operations.