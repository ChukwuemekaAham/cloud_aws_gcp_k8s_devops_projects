## MONITORING USING PROMETHEUS AND GRAFANA

grafana-all-nodes

What is Prometheus?
Prometheus is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. Since its inception in 2012, many companies and organizations have adopted Prometheus, and the project has a very active developer and user community. It is now a standalone open source project and maintained independently of any company. Prometheus joined the Cloud Native Computing Foundation in 2016 as the second hosted project, after Kubernetes.

What is Grafana?
Grafana is open source visualization and analytics software. It allows you to query, visualize, alert on, and explore your metrics no matter where they are stored. In plain English, it provides you with tools to turn your time-series database (TSDB) data into beautiful graphs and visualizations.

### INSTALL HELM CLI

Before we can get started configuring Helm, we’ll need to first install the command line tools that you will interact with. To do this, run the following:

`curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash`
We can verify the version

`helm version --short`

Let’s configure our first Chart repository. Chart repositories are similar to APT or yum repositories that you might be familiar with on Linux, or Taps for Homebrew on macOS.

*Download the stable repository so we have something to start with:*

`helm repo add stable https://charts.helm.sh/stable`
Once this is installed, we will be able to list the charts you can install:

`helm search repo stable`
Finally, let’s configure Bash completion for the helm command:

```bash
helm completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion
source <(helm completion bash)
```

NAME: prometheus
LAST DEPLOYED: Sun Dec  4 22:51:51 2022
NAMESPACE: prometheus
STATUS: deployed
REVISION: 1
NOTES:

The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:    
prometheus-server.prometheus.svc.cluster.local


Get the Prometheus server URL by running these commands in the same shell:
```bsh
  export POD_NAME=$(kubectl get pods --namespace prometheus -l "app=prometheus,component=server" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace prometheus port-forward $POD_NAME 9090
```


The Prometheus alertmanager can be accessed via port  on the following DNS name from within your cluster:

prometheus-%!s(<nil>).prometheus.svc.cluster.local


Get the Alertmanager URL by running these commands in the same shell:
  export POD_NAME=$(kubectl get pods --namespace prometheus -l "app=prometheus,component=" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace prometheus port-forward $POD_NAME 9093
#################################################################################
######   WARNING: Pod Security Policy has been disabled by default since    #####
######            it deprecated after k8s 1.25+. use                        #####
######            (index .Values "prometheus-node-exporter" "rbac"          #####
###### .          "pspEnabled") with (index .Values                         #####
######            "prometheus-node-exporter" "rbac" "pspAnnotations")       #####
######            in case you still need it.                                #####
#################################################################################


The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
prometheus-prometheus-pushgateway.prometheus.svc.cluster.local


Get the PushGateway URL by running these commands in the same shell:
```bash
  export POD_NAME=$(kubectl get pods --namespace prometheus -l "app=prometheus-pushgateway,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
  kubectl --namespace prometheus port-forward $POD_NAME 9091
```

For more information on running Prometheus, visit:
https://prometheus.io/



`kubectl get all -n prometheus`
NAME                                                     READY   STATUS    RESTARTS   AGE
pod/prometheus-alertmanager-0                            2/2     Running   0          93s
pod/prometheus-kube-state-metrics-7f99454c55-sqqr6       1/1     Running   0          93s
pod/prometheus-prometheus-node-exporter-7kmgh            1/1     Running   0          94s
pod/prometheus-prometheus-node-exporter-tl7lx            1/1     Running   0          94s
pod/prometheus-prometheus-node-exporter-xtqxj            1/1     Running   0          94s
pod/prometheus-prometheus-pushgateway-78bbf554c5-txgnh   1/1     Running   0          93s
pod/prometheus-server-9fb66957d-cmhpv                    2/2     Running   0          93s

NAME                                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE  
service/prometheus-alertmanager               ClusterIP   10.100.122.182   <none>        9093/TCP   96s  
service/prometheus-alertmanager-headless      ClusterIP   None             <none>        9093/TCP   96s  
service/prometheus-kube-state-metrics         ClusterIP   10.100.115.94    <none>        8080/TCP   96s  
service/prometheus-prometheus-node-exporter   ClusterIP   10.100.38.8      <none>        9100/TCP   96s  
service/prometheus-prometheus-pushgateway     ClusterIP   10.100.31.109    <none>        9091/TCP   96s
service/prometheus-server                     ClusterIP   10.100.251.151   <none>        80/TCP     96s  

NAME                                                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/prometheus-prometheus-node-exporter   3         3         3       3            3          
 <none>          96s

NAME                                                READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prometheus-kube-state-metrics       1/1     1            1           95s
deployment.apps/prometheus-prometheus-pushgateway   1/1     1            1           95s
deployment.apps/prometheus-server                   1/1     1            1           95s

NAME                                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/prometheus-kube-state-metrics-7f99454c55       1         1         1       95s
replicaset.apps/prometheus-prometheus-pushgateway-78bbf554c5   1         1         1       95s
replicaset.apps/prometheus-server-9fb66957d                    1         1         1       95s

NAME                                       READY   AGE
statefulset.apps/prometheus-alertmanager   1/1     96s




W1204 23:20:05.918062   19408 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W1204 23:20:13.824549   19408 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
NAME: grafana
LAST DEPLOYED: Sun Dec  4 23:20:03 2022
NAMESPACE: grafana
STATUS: deployed
REVISION: 1
NOTES:
1. Get your 'admin' user password by running:

   kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:    

   grafana.grafana.svc.cluster.local

   Get the Grafana URL to visit by running these commands in the same shell:
   NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        You can watch the status of by running 
        
    ```bash
     kubectl get svc --namespace grafana -w grafana`
     
     export SERVICE_IP=$(kubectl get svc --namespace grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
     http://$SERVICE_IP:80
     ```

3. Login with the password from step 1 and the username: admin


`kubectl get all -n grafana`
NAME                          READY   STATUS    RESTARTS   AGE
pod/grafana-bd65bccbc-hzgwg   1/1     Running   0          2m5s

NAME              TYPE           CLUSTER-IP       EXTERNAL-IP                                            
                   PORT(S)        AGE
service/grafana   LoadBalancer   10.100.118.155   acba6e7a800a6411b9f5e7b0815b7b71-1588108529.us-west-2.elb.amazonaws.com   80:31395/TCP   2m6s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/grafana   1/1     1            1           2m7s

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/grafana-bd65bccbc   1         1         1       2m7s 

## DASHBOARDS
Log in to Grafana
Log in to Grafana dashboard using credentials supplied during configuration.

You will notice that ‘Install Grafana’ & ‘create your first data source’ are already completed. We will import community created dashboard for this tutorial.

Cluster Monitoring Dashboard
For creating a dashboard to monitor the cluster:

Click '+' button on left panel and select ‘Import’.
Enter 3119 dashboard id under Grafana.com Dashboard.
Click ‘Load’.
Select ‘Prometheus’ as the endpoint under prometheus data sources drop down.
Click ‘Import’.
This will show monitoring dashboard for all cluster nodes

grafana-all-nodes

Pods Monitoring Dashboard
For creating a dashboard to monitor all the pods:

Click '+' button on left panel and select ‘Import’.
Enter 6417 dashboard id under Grafana.com Dashboard.
Click ‘Load’.
Enter Kubernetes Pods Monitoring as the Dashboard name.
Click change to set the Unique identifier (uid).
Select ‘Prometheus’ as the endpoint under prometheus data sources drop down.
Click ‘Import’.
grafana-all-pods


