#!/bin/bash

set -x

#To use IAM roles for service accounts in the cluster, 
#an OIDC identity provider need to be created

eksctl utils associate-iam-oidc-provider \
    --cluster eks-eksctl-demo \
    --approve

# Creating an IAM policy for the service account that will allow CA pod to interact with 
# the autoscaling groups.

aws iam create-policy   \
  --policy-name k8s-asg-policy \
  --policy-document file://~/environment/cluster-autoscaler/k8s-asg-policy.json

#IAM role for the cluster-autoscaler Service Account in the kube-system namespace.

eksctl create iamserviceaccount \
    --name cluster-autoscaler \
    --namespace kube-system \
    --cluster eks-eksctl-demo \
    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/k8s-asg-policy" \
    --approve \
    --override-existing-serviceaccounts


#To ensure service account with the ARN of the IAM role is annotated
kubectl -n kube-system describe sa cluster-autoscaler

# Output


# Name:                cluster-autoscaler
# Namespace:           kube-system
# Labels:              <none>
# Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::263022081217:role/eksctl-eks-eksctl-demo-addon-iamserviceac-Role1-12LNPCGBD6IPZ
# Image pull secrets:  <none>
# Mountable secrets:   cluster-autoscaler-token-vfk8n
# Tokens:              cluster-autoscaler-token-vfk8n
# Events:              <none>