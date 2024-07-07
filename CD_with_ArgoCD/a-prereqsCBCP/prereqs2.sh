#!/bin/bash

set -x

# Jq is a program developed to filter JSON data. You can consider Jq 
# like sed, awk, or grep program but designed specifically for filtering JSON data
# jq is not a built-in command. So, you have to install this command for using it.

# curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe
# jq --Version

# Use your account number below
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
aws s3 mb s3://eks-${ACCOUNT_ID}-codepipeline-artifacts

# cd ~/environment

aws iam create-role --role-name eks-argocd-CodePipelineServiceRole --assume-role-policy-document file://cpAssumeRolePolicyDocument.json 

aws iam put-role-policy --role-name eks-argocd-CodePipelineServiceRole --policy-name codepipeline-access --policy-document file://cpPolicyDocument.json

aws iam create-role --role-name eks-argocd-CodeBuildServiceRole --assume-role-policy-document file://cbAssumeRolePolicyDocument.json 

aws iam put-role-policy --role-name eks-argocd-CodeBuildServiceRole --policy-name codebuild-access --policy-document file://cbPolicyDocument.json
