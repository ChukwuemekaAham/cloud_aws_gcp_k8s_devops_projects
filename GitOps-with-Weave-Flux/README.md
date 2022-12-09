# GITOPS WITH WEAVE FLUX

This project aims at testing out Weave Flux CD workflow. Weave Flux is a tool that runs in Kubernetes cluster and implements changes based on monitoring Git and image repositories.

In this project, I created a Docker image build pipeline using AWS CodePipeline for a sample application in a GitHub repository, then commit Kubernetes manifests to GitHub and monitor Weave Flux managing the deployment. Git is used as single source of truth for deploying into the existing cluster.

Below is a diagram of what will be created:

<br>

![img](gitops_workflow.png)


