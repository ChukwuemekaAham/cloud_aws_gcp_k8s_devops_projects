## INSTALL ARGO CD

![img](argocd_architecture.png)

ArgoCD is composed of three mains components:

API Server: Exposes the API for the WebUI / CLI / CICD Systems

Repository Server: Internal service which maintains a local cache of the git repository holding the application manifests

Application Controller: Kubernetes controller which controls and monitors applications continuously and compares that current live state with desired target state (specified in the repository). If a OutOfSync is detected, it will take corrective actions.

*Install Argo CD:*

All those components could be installed using a manifest provided by the Argo Project:

```bash
./setup.sh
```
