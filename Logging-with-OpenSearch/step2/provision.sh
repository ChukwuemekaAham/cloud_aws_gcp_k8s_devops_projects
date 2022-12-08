#!/bin/bash

set -x

# name of our Amazon OpenSearch cluster
export ES_DOMAIN_NAME="eks-logging"

# Elasticsearch version
export ES_VERSION="OpenSearch_1.0"

# OpenSearch Dashboards admin user
export ES_DOMAIN_USER="adminopensearch"

# OpenSearch Dashboards admin password
export ES_DOMAIN_PASSWORD="$(openssl rand -base64 12)_Ek1$"


# Create the opensearch cluster
aws opensearch create-domain \
  --cli-input-json  file://~/environment/logging/es-domain.json


#check status
if [ $(aws opensearch describe-domain --domain-name ${ES_DOMAIN_NAME} --query 'DomainStatus.Processing') == "false" ]
  then
    tput setaf 2; echo "The Amazon OpenSearch cluster is ready"
  else
    tput setaf 1;echo "The Amazon OpenSearch cluster is NOT ready"
fi

# It is important to wait for the cluster to be available before proceeding