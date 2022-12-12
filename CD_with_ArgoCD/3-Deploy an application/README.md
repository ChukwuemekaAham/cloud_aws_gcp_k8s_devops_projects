## DEPLOY AN APPLICATION

We now have an ArgoCD fully deployed, we will now deploy an application (ecsdemo-nodejs).


url: https://github.com/ChukwuemekaAham/ecsdemo-nodejs.git 

### Create application

```bash
./deploy.sh
```

*output:*
```bash
$ ./deploy.sh
++ kubectl config view -o 'jsonpath={.current-context}'
+ CONTEXT_NAME=admin@eks-eksctl-demo.us-east-1.eksctl.io
+ argocd cluster add admin@eks-eksctl-demo.us-east-1.eksctl.io
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `admin@eks-eksctl-demo.us-east-1.eksctl.io` with full cluster level privileges. Do you want to continue [y/N]? y
time="2022-11-29T10:49:48+01:00" level=info msg="ServiceAccount \"argocd-manager\" created in namespace \"kube-system\""  
time="2022-11-29T10:49:48+01:00" level=info msg="ClusterRole \"argocd-manager-role\" created"
time="2022-11-29T10:49:48+01:00" level=info msg="ClusterRoleBinding \"argocd-manager-role-binding\" created"
Cluster 'https://B11A00554E690943EF058EC3722F83E3.gr7.us-east-1.eks.amazonaws.com' added
```

*ArgoCD provides multicluster deployment functionalities. But this project is deployed on the local cluster*.

*output:*
```bash
$ argocd app get ecsdemo-nodejs
Name:               argocd/ecsdemo-nodejs
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          ecsdemo-nodejs
URL:                https://af63b0a6a1bbd423fa1826318d2752b1-241410707.us-east-1.elb.amazonaws.com/applications/ecsdemo-nodejs
Repo:               https://github.com/ChukwuemekaAham/ecsdemo-nodejs.git
Target:
Path:               kubernetes
SyncWindow:         Sync Allowed
Sync Policy:        <none>
Sync Status:        OutOfSync from  (c61db33)
Health Status:      Missing

GROUP  KIND        NAMESPACE       NAME            STATUS     HEALTH   HOOK  MESSAGE
       Service     ecsdemo-nodejs  ecsdemo-nodejs  OutOfSync  Missing        
apps   Deployment  default         ecsdemo-nodejs  OutOfSync  Missing

```

The application is in an OutOfSync status since the application has not been deployed yet. We are now going to sync our application:

```bash
$ argocd app sync ecsdemo-nodejs

Name:               argocd/ecsdemo-nodejs
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          ecsdemo-nodejs
URL:                https://af63b0a6a1bbd423fa1826318d2752b1-241410707.us-east-1.elb.amazonaws.com/applications/ecsdemo-nodejs
Start:              2022-11-29 10:57:07 +0100 WAT
Finished:           2022-11-29 10:57:08 +0100 WAT
Duration:           1s
Message:            successfully synced (all tasks run)

GROUP  KIND        NAMESPACE       NAME            STATUS  HEALTH       HOOK  MESSAGE
       Service     ecsdemo-nodejs  ecsdemo-nodejs  Synced  Healthy            service/ecsdemo-nodejs created
apps   Deployment  default         ecsdemo-nodejs  Synced  Progressing        deployment.apps/ecsdemo-nodejs created

After a couple of minutes our application should be synchronized.

GROUP  KIND        NAMESPACE       NAME            STATUS  HEALTH   HOOK  MESSAGE
_      Service     ecsdemo-nodejs  ecsdemo-nodejs  Synced  Healthy        service/ecsdemo-nodejs created
apps   Deployment  default         ecsdemo-nodejs  Synced  Healthy        deployment.apps/ecsdemo-nodejs created

```