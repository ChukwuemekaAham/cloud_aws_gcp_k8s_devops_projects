Cluster Autoscaler vs. other types of Autoscalers
Before we explore the specifics of CA, let’s review the different types of autoscaling in Kubernetes. They are:

Cluster Autoscaler (CA): adjusts the number of nodes in the cluster when pods fail to schedule or when nodes are underutilized.
Horizontal Pod Autoscaler (HPA): adjusts the number of replicas of an application.
Vertical Pod Autoscaler (VPA): adjusts the resource requests and limits of a container.
A simple way to think about the Kubernetes autoscaling functionality is that HPA and VPA operate at the pod level, whereas CA works at the cluster level.


What is Cluster Autoscaler (CA)
The Cluster Autoscaler automatically adds or removes nodes in a cluster based on resource requests from pods. The Cluster Autoscaler doesn’t directly measure CPU and memory usage values to make a scaling decision. Instead, it checks every 10 seconds to detect any pods in a pending state, suggesting that the scheduler could not assign them to a node due to insufficient cluster capacity.

How Cluster Autoscaler (CA) works
In the scaling-up scenario, CA automatically kicks in when the number of pending (un-schedulable) pods increases due to resource shortages and works to add additional nodes to the cluster.

CA process img


The diagram above illustrates the Cluster Autoscaler decision-making process when there is a need to increase capacity. A similar mechanism exists for the scale-down scenario where CA may consolidate pods onto fewer nodes to free up a node and terminate it.

The four steps involved in scaling up a cluster are as follows:

When Cluster Autoscaler is active, it will check for pending pods. The default scan interval is 10 seconds, which is configurable using the --scan-interval flag.
If there are any pending pods and the cluster needs more resources, CA will extend the cluster by launching a new node as long as it is within the constraints configured by the administrator (more on this in our example). Public cloud providers like AWS, Azure, GCP also support the Kubernetes Cluster Autoscaler functionality. For example, AWS EKS integrates into Kubernetes using its AWS Auto Scaling group functionality to automatically add and remove EC2 virtual machines that serve as cluster nodes.
Kubernetes registers the newly provisioned node with the control plane to make it available to the Kubernetes scheduler for assigning pods.
Finally, the Kubernetes scheduler allocates the pending pods to the new node.
Limitations of CA
Cluster Autoscaler has a couple of limitations worth keeping in mind when planning your implementation:

CA does not make scaling decisions using CPU or memory usage. It only checks a pod’s requests and limits for CPU and memory resources. This limitation means that the unused computing resources requested by users will not be detected by CA, resulting in a cluster with waste and low utilization efficiency.
Whenever there is a request to scale up the cluster, CA issues a scale-up request to a cloud provider within 30–60 seconds. The actual time the cloud provider takes to create a node can be several minutes or more. This delay means that your application performance may be degraded while waiting for the extended cluster capacity.


EKS Example: How to implement Cluster Autoscaler
Next, we’ll follow step-by-step instructions to implement the Kubernetes CA functionality in AWS Elastic Kubernetes Service (EKS). EKS uses the AWS Auto Scaling group (which we’ll occasionally refer to as “ASG”) functionality to integrate with CA and execute its requests for adding and removing nodes. Below are the seven steps that we will step through as part of this exercise.

Review the prerequisites for Cluster Autoscaler
Create an EKS cluster in AWS
Create IAM OIDC provider
Create IAM policy for Cluster Autoscaler
Create IAM role for Cluster Autoscaler
Deploy Kubernetes Cluster Autoscaler
Create an Nginx deployment to test the CA functionality

Next, use eksctl to create the EKS cluster using the command shown below.

`eksctl create cluster -f eks-ca.yaml`

Here, we are creating two Auto Scaling groups for the cluster (behind the scenes, AWS EKS uses node groups to simplify the node’s lifecycle management):

Managed-nodes
Unmanaged-nodes
We will use the unmanaged nodes later in this exercise as part of a test to verify the proper functioning of the Cluster Autoscaler.

## create IRSA 

```shell
./irsa.sh
```

Deploy the Cluster Autoscaler to your cluster with the following command.

`kubectl apply -f cluster-autoscaler-autodiscover.yaml`


To prevent CA from removing nodes where its own pod is running, we will add the cluster-autoscaler.kubernetes.io/safe-to-evict annotation to its deployment with the following command

```bash
kubectl -n kube-system \
    annotate deployment.apps/cluster-autoscaler \
    cluster-autoscaler.kubernetes.io/safe-to-evict="false"
```

Finally let’s update the autoscaler image

# we need to retrieve the latest docker image available for our EKS version

```shell
./latest-img.sh
```

Watch the logs

`kubectl -n kube-system logs -f deployment/cluster-autoscaler`


## SCALE A CLUSTER WITH CA

Deploy a Sample App

We will deploy an sample nginx application as a ReplicaSet of 1 Pod

`kubectl apply -f ~/environment/cluster-autoscaler/nginx.yaml`

`kubectl get deployment/nginx-to-scaleout`


Scale our ReplicaSet
Let’s scale out the replicaset to 10

`kubectl scale --replicas=10 deployment/nginx-to-scaleout`

Some pods will be in the Pending state, which triggers the cluster-autoscaler to scale out the EC2 fleet.

`kubectl get pods -l app=nginx -o wide --watch`

```bash

NAME                                 READY     STATUS    RESTARTS   AGE

nginx-to-scaleout-7cb554c7d5-2d4gp   0/1       Pending   0          11s
nginx-to-scaleout-7cb554c7d5-2nh69   0/1       Pending   0          12s
nginx-to-scaleout-7cb554c7d5-45mqz   0/1       Pending   0          12s
nginx-to-scaleout-7cb554c7d5-4qvzl   0/1       Pending   0          12s
nginx-to-scaleout-7cb554c7d5-5jddd   1/1       Running   0          34s
nginx-to-scaleout-7cb554c7d5-5sx4h   0/1       Pending   0          12s
nginx-to-scaleout-7cb554c7d5-5xbjp   0/1       Pending   0          11s
nginx-to-scaleout-7cb554c7d5-6l84p   0/1       Pending   0          11s
nginx-to-scaleout-7cb554c7d5-7vp7l   0/1       Pending   0          12s
nginx-to-scaleout-7cb554c7d5-86pr6   0/1       Pending   0          12s
nginx-to-scaleout-7cb554c7d5-88ttw   0/1       Pending   0          12s
```

View the cluster-autoscaler logs

`kubectl -n kube-system logs -f deployment/cluster-autoscaler`


Check the EC2 AWS Management Console to confirm that the Auto Scaling groups are scaling up to meet demand. This may take a few minutes. You can also follow along with the pod deployment from the command line. You should see the pods transition from pending to running as nodes are scaled up.


or by using the kubectl

`kubectl get nodes`

Output

```bash
ip-192-168-12-114.us-west-2.compute.internal   Ready    <none>   3d6h   v1.17.7-eks-bffbac
ip-192-168-29-155.us-west-2.compute.internal   Ready    <none>   63s    v1.17.7-eks-bffbac
ip-192-168-55-187.us-west-2.compute.internal   Ready    <none>   3d6h   v1.17.7-eks-bffbac
ip-192-168-82-113.us-west-2.compute.internal   Ready    <none>   8h     v1.17.7-eks-bffbac
```