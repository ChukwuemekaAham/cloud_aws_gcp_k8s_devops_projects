#!/bin/bash

set -x

#To use IAM roles for service accounts in the cluster, 
#an OIDC identity provider need to be created

eksctl utils associate-iam-oidc-provider \
    --cluster eks-eksctl-demo \
    --approve

# IAM policy that limits the permissions needed by the Fluent Bit
# containers to connect to the Elasticsearch cluster.
# IAM role for your Kubernetes service accounts to use before it is
# associated with a service account.

aws iam create-policy   \
  --policy-name fluent-bit-policy \
  --policy-document file://~/environment/logging/fluent-bit-policy.json


#IAM role for the fluent-bit Service Account in the logging namespace.

kubectl create namespace logging

eksctl create iamserviceaccount \
    --name fluent-bit \
    --namespace logging \
    --cluster eks-eksctl-demo \
    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/fluent-bit-policy" \
    --approve \
    --override-existing-serviceaccounts

#To ensure service account with the ARN of the IAM role is annotated
kubectl -n logging describe sa fluent-bit