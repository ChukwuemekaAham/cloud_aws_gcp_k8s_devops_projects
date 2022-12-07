#!/bin/bash

set -x

TRUST="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"AWS\": \"arn:aws:iam::${ACCOUNT_ID}:root\" }, \"Action\": \"sts:AssumeRole\" } ] }"

echo '{ "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Action": "eks:Describe*", "Resource": "*" } ] }' > ~/tmp/iam-role-policy

aws iam create-role --role-name EksCodeBuildKubectlRole --assume-role-policy-document "$TRUST" --output text --query 'Role.Arn'

aws iam put-role-policy --role-name EksCodeBuildKubectlRole --policy-name eks-describe --policy-document file://~/tmp/iam-role-policy



# TRUST="{ \"Version\": \"2012-10-17\", \"Statement\": [ { \"Effect\": \"Allow\", \"Principal\": { \"AWS\": \"arn:aws:iam::${ACCOUNT_ID}:root\" }, \"Action\": \"sts:AssumeRole\" } ] }"

# echo '{ "Version": "2012-10-17", "Statement": [ {"Effect": "Allow","Action": ["eks:ListFargateProfiles","eks:DescribeNodegroup","eks:ListNodegroups","eks:ListUpdates","eks:AccessKubernetesApi","eks:ListAddons","eks:DescribeCluster","eks:DescribeAddonVersions","eks:ListClusters","eks:ListIdentityProviderConfigs","iam:ListRoles"],"Resource": "*"},{"Effect": "Allow","Action": "ssm:GetParameter","Resource": "arn:aws:ssm:*:559379197057:parameter/*"} ] }' > ~/tmp/eks-role-policy

# aws iam create-role --role-name EksKubectlRole --assume-role-policy-document "$TRUST" --output text --query 'Role.Arn'

# aws iam put-role-policy --role-name EksKubectlRole --policy-name eksuser-describe --policy-document file://~/tmp/eks-role-policy




#eksctl create iamidentitymapping --cluster eks-eksctl-demo  --region=us-east-1 --arn arn:aws:iam::559379197057:role/EksKubectlRole --group system:masters --username admin