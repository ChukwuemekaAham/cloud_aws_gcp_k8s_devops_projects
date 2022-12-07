## AUTOMATIC NODE PROVISIONING
With Karpenter now active, we can begin to explore how Karpenter provisions nodes. Here I create some pods using a deployment we will watch Karpenter provision nodes in response.

In this part off, we will use a Deployments with the pause image. If you are not familiar with Pause Pods you can read more about them [here](https://www.ianlewis.org/en/almighty-pause-container.) 

If you're using the Kubernetes Cluster Autoscaler, scale the deployment down to zero (0) replicas to avoid conflicting scaling actions.

The initial replica for the inflate.yaml deployment is set to zero(0) for convenience too. Karpenter will not scale the cluster after making the initial deployment. We can verify from the initial log after the first deployment has completed.

*RUN:*
`kubectl apply -f inflate.yaml`

deployment.apps/inflate created



NOTE: 
- Karpenter does support scale; to and from Zero. 
- Karpenter only launches or terminates nodes as necessary based on aggregate pod resource requests. 
- Karpenter will only retain nodes in your cluster as long as there are pods using them.
- Karpenter scales up nodes in a group-less approach. 
- Karpenter select which nodes to scale , based on the number of pending pods and the Provisioner configuration. 
- It selects how the best instances for the workload should look like, and then provisions those instances. This is unlike what Cluster Autoscaler does. 
- In the case of Cluster Autoscaler, first all existing node group are evaluated and to find which one is the best placed to scale, given the Pod constraints.
- Karpenter uses cordon and drain best practices to terminate nodes. The configuration of when a node is terminated can be controlled with ttlSecondsAfterEmpty
- Karpenter can scale-out from zero when applications have available working pods and scale-in to zero when there are no running jobs or pods.

-Provisioners can be setup to define governance and rules that define how nodes will be provisioned within a cluster partition. 
- We can setup requirements such as karpenter.sh/capacity-type to allow on-demand and spot instances or use karpenter.k8s.aws/instance-size to filter smaller sizes. 
- The full list of supported labels is available [here](https://karpenter.sh/v0.13.1/tasks/scheduling/#selecting-nodes)







