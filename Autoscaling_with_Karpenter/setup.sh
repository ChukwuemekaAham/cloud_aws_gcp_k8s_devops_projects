#!/bin/bash

set -x

export KARPENTER_VERSION=v0.19.3

# Create the KarpenterNode IAM Role
# Instances launched by Karpenter must run with an InstanceProfile that grants 
# permissions necessary to run containers and configure networking. 
# Karpenter discovers the InstanceProfile using the name KarpenterNodeRole-${ClusterName}.

# First, we create the IAM resources using AWS CloudFormation.

TEMPOUT=$(mktemp)

curl -fsSL https://karpenter.sh/"${KARPENTER_VERSION}"/getting-started/getting-started-with-eksctl/cloudformation.yaml  > $TEMPOUT \
&& aws cloudformation deploy \
  --stack-name "Karpenter-${CLUSTER_NAME}" \
  --template-file "${TEMPOUT}" \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides "ClusterName=${CLUSTER_NAME}"

# output:
# Waiting for changeset to be created..
# Waiting for stack create/update to complete
# Successfully created/updated stack - Karpenter-eks-eksctl-demo

# Second, we grant access to instances using the profile to connect to the cluster. 
# This command adds the Karpenter node role to the aws-auth configmap, allowing 
# nodes with this role to connect to the cluster.

eksctl create iamidentitymapping \
  --username system:node:{{EC2PrivateDNSName}} \
  --cluster  ${CLUSTER_NAME} \
  --arn "arn:aws:iam::${ACCOUNT_ID}:role/KarpenterNodeRole-${CLUSTER_NAME}" \
  --group system:bootstrappers \
  --group system:nodes

# output:
# 2022-12-05 16:27:07 [ℹ]  checking arn arn:aws:iam::263022081217:role/KarpenterNodeRole-eks-eksctl-demo against entries in the auth ConfigMap
# 2022-12-05 16:27:07 [ℹ]  adding identity "arn:aws:iam::263022081217:role/KarpenterNodeRole-eks-eksctl-demo" to auth ConfigMap

# we can verify the entry is now in the AWS auth map by running the following command.

kubectl describe configmap -n kube-system aws-auth

# Create KarpenterController IAM Role

# Before adding the IAM Role for the service account we need to create the IAM OIDC 
# Identity Provider for the cluster.

eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} --approve

#output:
# 2022-12-05 16:39:20 [ℹ]  will create IAM Open ID Connect provider for cluster "eks-eksctl-demo" in "us-west-2"
# 2022-12-05 16:39:22 [✔]  created IAM Open ID Connect provider for cluster "eks-eksctl-demo" in "us-west-2"

# Karpenter requires permissions like launching instances. This will create an AWS IAM Role, 
# Kubernetes service account, and associate them using IAM Roles for Service Accounts (IRSA)

eksctl create iamserviceaccount \
  --cluster "${CLUSTER_NAME}" --name karpenter --namespace karpenter \
  --role-name "${CLUSTER_NAME}-karpenter" \
  --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}" \
  --role-only \
  --approve

#output:
# 2022-12-05 16:42:50 [ℹ]  1 iamserviceaccount (karpenter/karpenter) was included (based on the include/exclude rules)
# 2022-12-05 16:42:50 [!]  serviceaccounts that exist in Kubernetes will be excluded, use --override-existing-serviceaccounts to override
# 2022-12-05 16:42:50 [ℹ]  1 task: { create IAM role for serviceaccount "karpenter/karpenter" }
# 2022-12-05 16:42:50 [ℹ]  building iamserviceaccount stack "eksctl-eks-eksctl-demo-addon-iamserviceaccount-karpenter-karpenter"
# 2022-12-05 16:42:50 [ℹ]  deploying stack "eksctl-eks-eksctl-demo-addon-iamserviceaccount-karpenter-karpenter"
# 2022-12-05 16:42:51 [ℹ]  waiting for CloudFormation stack "eksctl-eks-eksctl-demo-addon-iamserviceaccount-karpenter-karpenter"
# 2022-12-05 16:43:22 [ℹ]  waiting for CloudFormation stack "eksctl-eks-eksctl-demo-addon-iamserviceaccount-karpenter-karpenter"

export KARPENTER_IAM_ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${CLUSTER_NAME}-karpenter"


# This step may take up to 2 minutes. eksctl will create and deploy a CloudFormation stack 
# that defines the role and create the kubernetes resources that define the Karpenter 
# serviceaccount and the karpenter namespace that will be used. 
# You can also check in the CloudFormation console, the resources this stack creates.


# Create the EC2 Spot Linked Role
# Finally, we will create the spot EC2 Spot Linked role.

aws iam create-service-linked-role --aws-service-name spot.amazonaws.com

#output:
# {
#     "Role": {
#         "Path": "/aws-service-role/spot.amazonaws.com/",
#         "RoleName": "AWSServiceRoleForEC2Spot",
#         "RoleId": "AROAT2PKWOTATZXL3Q5KD",
#         "Arn": "arn:aws:iam::263022081217:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",        
#         "CreateDate": "2022-12-05T15:52:47+00:00",
#         "AssumeRolePolicyDocument": {
#             "Version": "2012-10-17",
#             "Statement": [
#                 {
#                     "Action": [
#                         "sts:AssumeRole"
#                     ],
#                     "Effect": "Allow",
#                     "Principal": {
#                         "Service": [
#                             "spot.amazonaws.com"
#                         ]
#                     }
#                 }
#             ]
#         }
#     }
# }
