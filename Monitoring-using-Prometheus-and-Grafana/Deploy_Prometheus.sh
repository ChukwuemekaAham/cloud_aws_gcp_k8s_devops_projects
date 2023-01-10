#!/bin/bash

set -x

# Deploy Prometheus
# First we are going to install Prometheus. In this example, we are primarily going to use 
# the standard configuration, but we do override the storage class. We will use gp2 EBS volumes 
# for simplicity and demonstration purpose. When deploying in production, you would use io1 volumes
# with desired IOPS and increase the default storage size in the manifests to get better performance.
# Run the following command:


kubectl create namespace prometheus

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"

kubectl get all -n prometheus

kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090

kubectl --namespace=prometheus port-forward deploy/prometheus-server 9090


# $ kubectl --namespace=prometheus port-forward deploy/prometheus-server 9090
# Forwarding from 127.0.0.1:9090 -> 9090
# Forwarding from [::1]:9090 -> 9090
# Handling connection for 9090
# Handling connection for 9090
# Handling connection for 9090



