### DEPLOY THE KUBERNETES DASHBOARD

The official Kubernetes dashboard is not deployed by default.

We can deploy the dashboard with the following command:

```bash
./setup.sh
```

### ACCESS THE DASHBOARD

Retrieve an authentication token for the eks-admin service account.

`kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')`

*output:*

```bash
Name:         eks-admin-token-b5zv4
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=eks-admin
              kubernetes.io/service-account.uid=bcfe66ac-39be-11e8-97e8-026dce96b6e8

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      authentication-token
```

Dashboard endpoint - open the similar link with a web browser: 

http://localhost:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login.


Open a New Terminal Tab and enter

`aws eks get-token --cluster-name eks-eksctl-demo | jq -r '.status.token'`

Copy the output of this command and then click the radio button next to Token 
then in the text field below paste the output from the last command.

Then press Sign In.



### CLEANUP
Stop the proxy and delete the dashboard deployment

```bash
./Cleanup.sh
```