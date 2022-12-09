#!/bin/bash

set -x


#Delete Weave Flux and load balanced services

helm uninstall helm-operator --namespace flux
helm uninstall flux --namespace flux
kubectl delete namespace flux 
kubectl delete crd helmreleases.helm.fluxcd.io

helm uninstall mywebserver -n nginx
kubectl delete namespace nginx
kubectl delete svc eks-example -n eks-example
kubectl delete deployment eks-example -n eks-example
kubectl delete namespace eks-example

#Remove IAM roles previously created

aws iam delete-role-policy --role-name eksworkshop-CodePipelineServiceRole --policy-name codepipeline-access 
aws iam delete-role --role-name eksworkshop-CodePipelineServiceRole
aws iam delete-role-policy --role-name eksworkshop-CodeBuildServiceRole --policy-name codebuild-access 
aws iam delete-role --role-name eksworkshop-CodeBuildServiceRole
Remove the artifact bucket you previously created

ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
aws s3 rb s3://eks-${ACCOUNT_ID}-codepipeline-artifacts --force
