we are going to install Kube-ops-view https://github.com/hjacobs/kube-ops-view from Henning Jacobs.
Kube-ops-view provides a common operational picture for a Kubernetes cluster that 
helps with understanding our cluster setup in a visual way.

We will deploy kube-ops-view using Helm configured in a previous module

The following line updates the stable helm repository and then installs kube-ops-view 
using a LoadBalancer Service type and creating a RBAC (Resource Base Access Control) 
entry for the read-only service account to read nodes and pods information from the cluster.

```shell
./kube-ops-view/install.sh
```

The execution above installs kube-ops-view exposing it through a Service using the LoadBalancer type. A successful execution of the command will display the set of resources created and will prompt some advice asking you to use kubectl proxy and a local URL for the service. Given we are using the type LoadBalancer for our service, we can disregard this; Instead we will point our browser to the external load balancer.

**warning:**
Monitoring and visualization shouldn’t be typically be exposed publicly unless the service is properly secured and provide methods for authentication and authorization. You can still deploy kube-ops-view using a Service of type ClusterIP by removing the --set service.type=LoadBalancer section and using kubectl proxy. Kube-ops-view does also support Oauth 2

`helm list`

NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                APP VERSION
kube-ops-view   default         1               2022-12-06 13:10:10.7174916 +0100 WAT   deployed        kube-ops-view-1.2.4  20.4.0



With this we can explore kube-ops-view output by checking the details about the newly service created.


`kubectl get svc kube-ops-view | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'`

This will display a line similar to Kube-ops-view URL = http://<URL_PREFIX_ELB>.amazonaws.com

Kube-ops-view URL = http://a63354bdc28104e92aeaff7901713047-821939958.us-west-2.elb.amazonaws.com

Opening the URL in your browser will provide the current state of our cluster.

You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; usually in two minutes you should see kub-ops-view.

We can perform scale up and down actions and can check the effects and changes in the cluster using kube-ops-view.

