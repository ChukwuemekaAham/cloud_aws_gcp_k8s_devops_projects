### UPDATE THE APPLICATION

The application is now deployed into our ArgoCD. 

Update spec.replicas: 2 in ecsdemo-nodejs/kubernetes/deployment.yaml

Once changes are made and it is committed and pushed using the below commands:

```bash
git add .
git commit -m "Your message"
git push 
```

*Access ArgoCD Web Interface*
To deploy our change we can access to ArgoCD UI with the Load Balancer url:

```bash
echo $ARGOCD_SERVER
Login using admin / $ARGO_PWD. 
```

You now have access to the ecsdemo-nodejds application. After clicking to refresh button status should be OutOfSync:

This means our Github repository is not synchronised with the deployed application. To fix this and deploy the new version (with 2 replicas) click on the sync button, and select the APPS/DEPLOYMENT/DEFAULT/ECSDEMO-NODEJS and SYNCHRONIZE:

After the sync completed our application should have the Synced status with 2 pods:
