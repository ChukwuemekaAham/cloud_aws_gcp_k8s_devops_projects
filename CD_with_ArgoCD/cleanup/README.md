### CLEANUP
Congratulations on completing the Continuous Deployment with ArgoCD module.

This module is not used in subsequent steps, so you can remove the resources now, or at the end of the workshop:

```bash
argocd app delete ecsdemo-nodejs -y
watch argocd app get ecsdemo-nodejs
```
Wait until all ressources are cleared with this message:

FATA[0000] rpc error: code = NotFound desc = applications.argoproj.io "ecsdemo-nodejs" not found 
And then delete ArgoCD from your cluster:

```bash
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
```

Delete namespaces created for this chapter:
```bash
kubectl delete ns argocd
kubectl delete ns ecsdemo-nodejs
```

You may also delete the cloned repository ecsdemo-nodejs within your GitHub account.



## OUTPUTS

$ argocd app delete ecsdemo-nodejs -y
time="2022-11-29T11:08:48+01:00" level=fatal msg="rpc error: code = NotFound desc = error getting application: applications.argoproj.io \"ecsdemo-nodejs\" not found"

HP@DESKTOP-9MLLT14 MINGW64 ~/Documents/AWS Partner Network -Turing/AWS Security + DevOps/AWS DevOps Professional/Step 7 Learn how to automate various deployment types/EKS Workshop/continuous_deployment_with_argocd
$ watch argocd app get ecsdemo-nodejs
bash: watch: command not found

HP@DESKTOP-9MLLT14 MINGW64 ~/Documents/AWS Partner Network -Turing/AWS Security + DevOps/AWS DevOps Professional/Step 7 Learn how to automate various deployment types/EKS Workshop/continuous_deployment_with_argocd
$ kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
Warning: deleting cluster-scoped resources, not scoped to the provided namespace
customresourcedefinition.apiextensions.k8s.io "applications.argoproj.io" deleted
customresourcedefinition.apiextensions.k8s.io "applicationsets.argoproj.io" deleted
customresourcedefinition.apiextensions.k8s.io "appprojects.argoproj.io" deleted
serviceaccount "argocd-application-controller" deleted
serviceaccount "argocd-applicationset-controller" deleted
serviceaccount "argocd-dex-server" deleted
serviceaccount "argocd-notifications-controller" deleted
serviceaccount "argocd-redis" deleted
serviceaccount "argocd-repo-server" deleted
serviceaccount "argocd-server" deleted
role.rbac.authorization.k8s.io "argocd-application-controller" deleted
role.rbac.authorization.k8s.io "argocd-applicationset-controller" deleted
role.rbac.authorization.k8s.io "argocd-dex-server" deleted
role.rbac.authorization.k8s.io "argocd-notifications-controller" deleted
role.rbac.authorization.k8s.io "argocd-server" deleted
clusterrole.rbac.authorization.k8s.io "argocd-application-controller" deleted
clusterrole.rbac.authorization.k8s.io "argocd-server" deleted
rolebinding.rbac.authorization.k8s.io "argocd-application-controller" deleted
rolebinding.rbac.authorization.k8s.io "argocd-applicationset-controller" deleted
rolebinding.rbac.authorization.k8s.io "argocd-dex-server" deleted
rolebinding.rbac.authorization.k8s.io "argocd-notifications-controller" deleted
rolebinding.rbac.authorization.k8s.io "argocd-redis" deleted
rolebinding.rbac.authorization.k8s.io "argocd-server" deleted
clusterrolebinding.rbac.authorization.k8s.io "argocd-application-controller" deleted
clusterrolebinding.rbac.authorization.k8s.io "argocd-server" deleted
service "argocd-repo-server" deleted
service "argocd-server" deleted
service "argocd-server-metrics" deleted
deployment.apps "argocd-applicationset-controller" deleted
deployment.apps "argocd-dex-server" deleted
deployment.apps "argocd-notifications-controller" deleted
deployment.apps "argocd-redis" deleted
deployment.apps "argocd-repo-server" deleted
deployment.apps "argocd-server" deleted
statefulset.apps "argocd-application-controller" deleted
networkpolicy.networking.k8s.io "argocd-application-controller-network-policy" deleted
networkpolicy.networking.k8s.io "argocd-dex-server-network-policy" deleted
networkpolicy.networking.k8s.io "argocd-redis-network-policy" deleted
networkpolicy.networking.k8s.io "argocd-repo-server-network-policy" deleted
networkpolicy.networking.k8s.io "argocd-server-network-policy" deleted

HP@DESKTOP-9MLLT14 MINGW64 ~/Documents/AWS Partner Network -Turing/AWS Security + DevOps/AWS DevOps Professional/Step 7 Learn how to automate various deployment types/EKS Workshop/continuous_deployment_with_argocd
$ kubectl delete ns argocd
namespace "argocd" deleted

HP@DESKTOP-9MLLT14 MINGW64 ~/Documents/AWS Partner Network -Turing/AWS Security + DevOps/AWS DevOps Professional/Step 7 Learn how to automate various deployment types/EKS Workshop/continuous_deployment_with_argocd
$ kubectl delete ns ecsdemo-nodejs
namespace "ecsdemo-nodejs" deleted