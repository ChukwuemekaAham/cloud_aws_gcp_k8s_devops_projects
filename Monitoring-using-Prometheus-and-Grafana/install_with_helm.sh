#!/bin/bash

set -x

# We will use helm to install Prometheus & Grafana monitoring tools

# add prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# add grafana Helm repo
helm repo add grafana https://grafana.github.io/helm-charts