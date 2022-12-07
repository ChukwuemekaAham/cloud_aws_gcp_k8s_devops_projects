**You can use Kube-ops-view or just plain kubectl cli to visualize the changes.**

Install kube-ops-view
*RUN:*
```shell
./kube-ops-view/install.sh
```

To scale up the deployment run:

`kubectl scale deployment inflate --replicas 1`

deployment.apps/inflate scaled

You can check the state of the replicas by running the following command. Once Karpenter provisions the new instance the pod will be placed in the new node.

`kubectl get deployment inflate `

NAME      READY   UP-TO-DATE   AVAILABLE   AGE
inflate   1/1     1            1           32m


You can check which instance type was used running the following command:

`kubectl get node --selector=intent=apps --show-labels`

This will show a single instance created with the label set to intent: apps. 

NAME                                            STATUS   ROLES    AGE     VERSION                LABELS
ip-192-168-185-111.us-west-2.compute.internal   Ready    <none>   7m42s   v1.21.14-eks-fb459a0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=r5.xlarge,beta.kubernetes.io/os=linux,failure-domain.beta.kubernetes.io/region=us-west-2,failure-domain.beta.kubernetes.io/zone=us-west-2d,intent=apps,k8s.io/cloud-provider-aws=1ca89af3decf1ea3b0004c0db2033941,karpenter.k8s.aws/instance-category=r,karpenter.k8s.aws/instance-cpu=4,karpenter.k8s.aws/instance-family=r5,karpenter.k8s.aws/instance-generation=5,karpenter.k8s.aws/instance-hypervisor=nitro,karpenter.k8s.aws/instance-memory=32768,karpenter.k8s.aws/instance-pods=58,karpenter.k8s.aws/instance-size=xlarge,karpenter.sh/capacity-type=spot,karpenter.sh/initialized=true,karpenter.sh/provisioner-name=default,kubernetes.io/arch=amd64,kubernetes.io/hostname=ip-192-168-185-111.us-west-2.compute.internal,kubernetes.io/os=linux,node.kubernetes.io/instance-type=r5.xlarge,topology.kubernetes.io/region=us-west-2,topology.kubernetes.io/zone=us-west-2d

To get the type of instance in this case, we can describe the node and look at the label beta.kubernetes.io/instance-type

`echo type: $(kubectl describe node --selector=intent=apps | grep "beta.kubernetes.io/instance-type" | sed s/.*=//g)`

*output:*
type: r5.xlarge

learn about how the node was provisioned. Check out Karpenter logs and look at the new Karpenter created. 

*output:*
```bash
2022-12-06T12:34:29.256Z        INFO    controller.provisioning Found 1 provisionable pod(s)    {"commit": "5d4ae35-dirty"}
2022-12-06T12:34:29.256Z        INFO    controller.provisioning Computed 1 new node(s) will fit 1 pod(s)        {"commit": "5d4ae35-dirty"}
2022-12-06T12:34:29.264Z        INFO    controller.provisioning Launching node with 1 pods requesting {"cpu":"1125m","memory":"1536Mi","pods":"3"} from types t3a.xlarge, t3.xlarge, m3.xlarge, c5ad.xlarge, c5d.xlarge and 358 other(s)  
        {"commit": "5d4ae35-dirty", "provisioner": "default"}
2022-12-06T12:34:29.557Z        DEBUG   controller.provisioning.cloudprovider   Discovered security groups: [sg-07d8abf2bf4846800 sg-0661b1489019eb52f]      {"commit": "5d4ae35-dirty", "provisioner": "default"}
2022-12-06T12:34:29.564Z        DEBUG   controller.provisioning.cloudprovider   Discovered kubernetes version 1.21   
        {"commit": "5d4ae35-dirty", "provisioner": "default"}
2022-12-06T12:34:29.599Z        DEBUG   controller.provisioning.cloudprovider   Discovered ami-02ff2f92f13947cbf for query "/aws/service/eks/optimized-ami/1.21/amazon-linux-2/recommended/image_id" {"commit": "5d4ae35-dirty", "provisioner": "default"}
2022-12-06T12:34:29.730Z        DEBUG   controller.provisioning.cloudprovider   Created launch template, Karpenter-eks-eksctl-demo-3485443203140799560       {"commit": "5d4ae35-dirty", "provisioner": "default"}
2022-12-06T12:34:32.034Z        INFO    controller.provisioning.cloudprovider   Launched instance: i-090e1217164a3b964, hostname: ip-192-168-185-111.us-west-2.compute.internal, type: r5.xlarge, zone: us-west-2d, capacityType: spot    
        {"commit": "5d4ae35-dirty", "provisioner": "default"}

```

Karpenter picks up the instance from a diversified selection of instances. In this case it selected the following instances:

`from types t3a.xlarge, t3.xlarge, m3.xlarge, c5ad.xlarge, c5d.xlarge and 358 other(s)  `
        
The types, ‘nano’, ‘micro’, ‘small’, ‘medium’, ‘large’, where filtered for this selection. While recommendation is to diversify on as many instances as possible, there are cases where provisioners may want to filter smaller (or specific) instances types.

Instances types might be different depending on the region selected.

All this instances are the suitable instances that reduce the waste of resources (memory and CPU) for the pod submitted. If you are interested in Algorithms, internally Karpenter is using a First Fit Decreasing (FFD) approach. Note however this can change in the future.

Karpenter Provisioner is set to use [EC2 Spot instances](https://aws.amazon.com/ec2/spot/), and there was no instance-types requirement section in the Provisioner to filter the type of instances. This means that Karpenter will use the default value of instances types to use. The default value includes all instance types with the exclusion of metal (non-virtualized), non-HVM, and GPU instances.Internally Karpenter used EC2 Fleet in Instant mode to provision the instances. You can read more about [EC2 Fleet Instant mode here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instant-fleet.html). Here are a few properties to mention about EC2 Fleet instant mode that are key for Karpenter.

EC2 Fleet instant mode provides a synchronous call to procure instances, including EC2 Spot, this simplifies and avoid error when provisioning instances. 

The call to EC2 Fleet in instant mode is done using capacity-optimized-prioritized selecting the instances that reduce the likelihood of provisioning an extremely large instance. Capacity-optimized allocation strategies select instances from the Spot capacity pools with optimal capacity for the number of instances launched thus reducing the frequency of Spot terminations for the instances selected. You can read more about [Allocation Strategies here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-fleet-allocation-strategy.html)

Calls to EC2 Fleet in instant mode are not considered as Spot fleets. They do not count towards the Spot Fleet limits. The implication is that Karpenter can make calls to this API as many times over time as needed.

By implementing techniques such as: Bin-packing using First Fit Decreasing, Instance diversification using EC2 Fleet instant fleet and capacity-optimized-prioritized, Karpenter removes the need from customer to define multiple Auto Scaling groups each one for the type of capacity constraints and sizes that all the applications need to fit in. This simplifies considerably the operational support of kubernetes clusters.

Instance properties; display all the node attributes including labels:

`kubectl describe node --selector=intent=apps`
*output:*

Name:               ip-192-168-185-111.us-west-2.compute.internal
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=r5.xlarge
                    beta.kubernetes.io/os=linux
                    failure-domain.beta.kubernetes.io/region=us-west-2
                    failure-domain.beta.kubernetes.io/zone=us-west-2d
                    intent=apps
                    k8s.io/cloud-provider-aws=1ca89af3decf1ea3b0004c0db2033941
                    karpenter.k8s.aws/instance-category=r
                    karpenter.k8s.aws/instance-cpu=4
                    karpenter.k8s.aws/instance-family=r5
                    karpenter.k8s.aws/instance-generation=5
                    karpenter.k8s.aws/instance-hypervisor=nitro
                    karpenter.k8s.aws/instance-memory=32768
                    karpenter.k8s.aws/instance-pods=58
                    karpenter.k8s.aws/instance-size=xlarge
                    karpenter.sh/capacity-type=spot
                    karpenter.sh/initialized=true
                    karpenter.sh/provisioner-name=default
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=ip-192-168-185-111.us-west-2.compute.internal
                    kubernetes.io/os=linux
                    node.kubernetes.io/instance-type=r5.xlarge
                    topology.kubernetes.io/region=us-west-2
                    topology.kubernetes.io/zone=us-west-2d
Annotations:        node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Tue, 06 Dec 2022 13:34:32 +0100
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  ip-192-168-185-111.us-west-2.compute.internal
  AcquireTime:     <unset>
  RenewTime:       Tue, 06 Dec 2022 14:07:04 +0100
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                
       Message
  ----             ------  -----------------                 ------------------                ------                
       -------
  MemoryPressure   False   Tue, 06 Dec 2022 14:05:35 +0100   Tue, 06 Dec 2022 13:35:02 +0100   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Tue, 06 Dec 2022 14:05:35 +0100   Tue, 06 Dec 2022 13:35:02 +0100   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Tue, 06 Dec 2022 14:05:35 +0100   Tue, 06 Dec 2022 13:35:02 +0100   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Tue, 06 Dec 2022 14:05:35 +0100   Tue, 06 Dec 2022 13:35:22 +0100   KubeletReady          
       kubelet is posting ready status
Addresses:
  InternalIP:   192.168.185.111
  Hostname:     ip-192-168-185-111.us-west-2.compute.internal
  InternalDNS:  ip-192-168-185-111.us-west-2.compute.internal
Capacity:
  attachable-volumes-aws-ebs:  25
  cpu:                         4
  ephemeral-storage:           20959212Ki
  hugepages-1Gi:               0
  hugepages-2Mi:               0
  memory:                      32409624Ki
  pods:                        58
Allocatable:
  attachable-volumes-aws-ebs:  25
  cpu:                         3920m
  ephemeral-storage:           18242267924
  hugepages-1Gi:               0
  hugepages-2Mi:               0
  memory:                      31392792Ki
  pods:                        58
System Info:
  Machine ID:                 ec27a9cae74039c652bed918374586ca
  System UUID:                ec27a9ca-e740-39c6-52be-d918374586ca
  Boot ID:                    d77ceffe-b69e-4cde-be79-15d703c401c6
  Kernel Version:             5.4.219-126.411.amzn2.x86_64
  OS Image:                   Amazon Linux 2
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.6.6
  Kubelet Version:            v1.21.14-eks-fb459a0
  Kube-Proxy Version:         v1.21.14-eks-fb459a0
ProviderID:                   aws:///us-west-2d/i-090e1217164a3b964
Non-terminated Pods:          (3 in total)
  Namespace                   Name                       CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                       ------------  ----------  ---------------  -------------  ---
  default                     inflate-b9d769f59-cntbc    1 (25%)       0 (0%)      1536Mi (5%)      0 (0%)         32m
  kube-system                 aws-node-lvdhq             25m (0%)      0 (0%)      0 (0%)           0 (0%)         32m
  kube-system                 kube-proxy-mhrtm           100m (2%)     0 (0%)      0 (0%)           0 (0%)         32m
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                    Requests     Limits
  --------                    --------     ------
  cpu                         1125m (28%)  0 (0%)
  memory                      1536Mi (5%)  0 (0%)
  ephemeral-storage           0 (0%)       0 (0%)
  hugepages-1Gi               0 (0%)       0 (0%)
  hugepages-2Mi               0 (0%)       0 (0%)
  attachable-volumes-aws-ebs  0            0
Events:
  Type     Reason                   Age                From             Message
  ----     ------                   ----               ----             -------
  Normal   RegisteredNode           32m                node-controller  Node ip-192-168-185-111.us-west-2.compute.internal event: Registered Node ip-192-168-185-111.us-west-2.compute.internal in Controller
  Normal   Starting                 32m                kubelet          Starting kubelet.
  Warning  InvalidDiskCapacity      32m                kubelet          invalid capacity 0 on image filesystem       
  Normal   NodeHasSufficientMemory  32m (x3 over 32m)  kubelet          Node ip-192-168-185-111.us-west-2.compute.internal status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    32m (x3 over 32m)  kubelet          Node ip-192-168-185-111.us-west-2.compute.internal status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     32m (x3 over 32m)  kubelet          Node ip-192-168-185-111.us-west-2.compute.internal status is now: NodeHasSufficientPID
  Normal   NodeAllocatableEnforced  32m                kubelet          Updated Node Allocatable limit across pods   
  Normal   Starting                 32m                kube-proxy       Starting kube-proxy.
  Normal   NodeReady                31m                kubelet          Node ip-192-168-185-111.us-west-2.compute.internal status is now: NodeReady
```


*REVIEW:*
Labels:             ...
                    intent=apps
                    karpenter.k8s.aws/instance-size=xlarge
                    karpenter.sh/capacity-type=spot
                    karpenter.sh/provisioner-name=default
                    node.kubernetes.io/instance-type=r5.xlarge
                    topology.kubernetes.io/region=us-west-2
                    topology.kubernetes.io/zone=us-west-2d
                    ...
- The node was created with the intent=apps as stated in the Provisioner configuration
Same applies to the Spot configuration. 
- The karpenter.sh/capacity-type label has been set to spot
- Karpenter AWS implementation will also add the Labels topology.kubernetes.io for region and zone.

Karpenter does support multiple Provisioners. The karpenter.sh/provisioner-name uses the default as the Provisioner in charge of managing the instance lifecycle.
Another thing to note from the node description is the following section:

System Info:
  ...
  OS Image:                   Amazon Linux 2
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.6.6
  ...

The instance selected has been created with the default architecture Karpenter will use when the Provisioner CRD requirement for kubernetes.io/arch Architecture has not been provided.

The Container Runtime used for Karpenter nodes is containerd. You can read more about containerd 
[here](https://containerd.io/)

The newly created inflate pod was not scheduled into the managed node group as the On-Demand Managed Node group was provisioned with the label intent set to control-apps. In our case the deployment defined the following section, where the intent is set to apps.

spec:
      nodeSelector:
        intent: apps
      containers:
        ...
Karpenter default Provisioner was also created with the the section:

spec:
  labels:
    intent: apps

NodeSelector, Taints and Tolerations, can be used to split the topology of the cluster and indicate Karpenter where to place Pods and Jobs.

Both Karpenter and Cluster Autoscaler do take into consideration NodeSelector, Taints and Tolerations. Mixing Autoscaling management solution in the same cluster may cause side effects as auto scaler systems like Cluster Autoscaler and Karpenter both scale up nodes in response to unschedulable pods. To avoid race conditions a clear division of the resources using NodeSelectors, Taints and Tolerations must be used.

Let's scale the number of replicas to 10

`kubectl scale deployment inflate --replicas 10`

deployment.apps/inflate scaled

This will set a few pods pending. Karpenter will get the pending pod signal and run a new provisioning cycle similar to the one below (confirm by checking Karpenter logs). This time, the capacity should get provisioned with a slightly different set of characteristics. Given the new size of aggregated pod requirements, Karpenter will check which type of instance diversification makes sense to use.

```bash
2022-12-06T13:23:55.286Z        INFO    controller.provisioning Found 7 provisionable pod(s)    {"commit": "5d4ae35-dirty"}
2022-12-06T13:23:55.287Z        INFO    controller.provisioning Computed 1 new node(s) will fit 7 pod(s)        {"commit": "5d4ae35-dirty"}
2022-12-06T13:23:55.294Z        INFO    controller.provisioning Launching node with 7 pods requesting {"cpu":"7125m","memory":"10752Mi","pods":"9"} from types t3a.2xlarge, t3.2xlarge, inf1.2xlarge, m3.2xlarge, c5d.2xlarge and 301 other(s)    {"commit": "5d4ae35-dirty", "provisioner": "default"}
2022-12-06T13:23:55.605Z        DEBUG   controller.provisioning.cloudprovider   Created launch template, Karpenter-eks-eksctl-demo-3485443203140799560       {"commit": "5d4ae35-dirty", "provisioner": "default"}
2022-12-06T13:23:57.814Z        INFO    controller.provisioning.cloudprovider   Launched instance: i-0237dc776b0ec9999, hostname: ip-192-168-121-67.us-west-2.compute.internal, type: m3.2xlarge, zone: us-west-2b, capacityType: spot    
        {"commit": "5d4ae35-dirty", "provisioner": "default"}
```

The instances selected this time are larger ! The instances selected were:

from types t3a.2xlarge, t3.2xlarge, inf1.2xlarge, m3.2xlarge, c5d.2xlarge and 301 other(s) 

Finally to check out the configuration of the intent=apps node execute again:

`kubectl describe node --selector=intent=apps`

Name:               ip-192-168-121-67.us-west-2.compute.internal
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=m3.2xlarge
                    beta.kubernetes.io/os=linux
                    failure-domain.beta.kubernetes.io/region=us-west-2
                    failure-domain.beta.kubernetes.io/zone=us-west-2b
                    intent=apps
                    k8s.io/cloud-provider-aws=1ca89af3decf1ea3b0004c0db2033941
                    karpenter.k8s.aws/instance-category=m
                    karpenter.k8s.aws/instance-cpu=8
                    karpenter.k8s.aws/instance-family=m3
                    karpenter.k8s.aws/instance-generation=3
                    karpenter.k8s.aws/instance-hypervisor=xen
                    karpenter.k8s.aws/instance-memory=30720
                    karpenter.k8s.aws/instance-pods=118
                    karpenter.k8s.aws/instance-size=2xlarge
                    karpenter.sh/capacity-type=spot
                    karpenter.sh/initialized=true
                    karpenter.sh/provisioner-name=default
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=ip-192-168-121-67.us-west-2.compute.internal
                    kubernetes.io/os=linux
                    node.kubernetes.io/instance-type=m3.2xlarge
                    topology.kubernetes.io/region=us-west-2
                    topology.kubernetes.io/zone=us-west-2b
Annotations:        node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Tue, 06 Dec 2022 14:23:57 +0100
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  ip-192-168-121-67.us-west-2.compute.internal
  AcquireTime:     <unset>
  RenewTime:       Tue, 06 Dec 2022 14:34:44 +0100
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                
       Message
  ----             ------  -----------------                 ------------------                ------                
       -------
  MemoryPressure   False   Tue, 06 Dec 2022 14:30:12 +0100   Tue, 06 Dec 2022 14:24:42 +0100   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Tue, 06 Dec 2022 14:30:12 +0100   Tue, 06 Dec 2022 14:24:42 +0100   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Tue, 06 Dec 2022 14:30:12 +0100   Tue, 06 Dec 2022 14:24:42 +0100   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Tue, 06 Dec 2022 14:30:12 +0100   Tue, 06 Dec 2022 14:25:12 +0100   KubeletReady          
       kubelet is posting ready status
Addresses:
  InternalIP:   192.168.121.67
  Hostname:     ip-192-168-121-67.us-west-2.compute.internal
  InternalDNS:  ip-192-168-121-67.us-west-2.compute.internal
Capacity:
  attachable-volumes-aws-ebs:  39
  cpu:                         8
  ephemeral-storage:           20959212Ki
  hugepages-2Mi:               0
  memory:                      30817808Ki
  pods:                        118
Allocatable:
  attachable-volumes-aws-ebs:  39
  cpu:                         7910m
  ephemeral-storage:           18242267924
  hugepages-2Mi:               0
  memory:                      29125136Ki
  pods:                        118
System Info:
  Machine ID:                 5b46eae6ae15414ea981178e320ad7be
  System UUID:                ec2885fd-29ef-adca-800a-f44411140dda
  Boot ID:                    a3e2743c-e530-4a08-bc68-4c302ed6ae8a
  Kernel Version:             5.4.219-126.411.amzn2.x86_64
  OS Image:                   Amazon Linux 2
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.6.6
  Kubelet Version:            v1.21.14-eks-fb459a0
  Kube-Proxy Version:         v1.21.14-eks-fb459a0
ProviderID:                   aws:///us-west-2b/i-0237dc776b0ec9999
Non-terminated Pods:          (9 in total)
  Namespace                   Name                       CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                       ------------  ----------  ---------------  -------------  ---
  default                     inflate-b9d769f59-2frx5    1 (12%)       0 (0%)      1536Mi (5%)      0 (0%)         10m
  default                     inflate-b9d769f59-b7vhs    1 (12%)       0 (0%)      1536Mi (5%)      0 (0%)         10m
  default                     inflate-b9d769f59-lglqt    1 (12%)       0 (0%)      1536Mi (5%)      0 (0%)         10m
  default                     inflate-b9d769f59-lpnhs    1 (12%)       0 (0%)      1536Mi (5%)      0 (0%)         10m
  default                     inflate-b9d769f59-rbv87    1 (12%)       0 (0%)      1536Mi (5%)      0 (0%)         10m
  default                     inflate-b9d769f59-wp87g    1 (12%)       0 (0%)      1536Mi (5%)      0 (0%)         10m
  default                     inflate-b9d769f59-wpjjj    1 (12%)       0 (0%)      1536Mi (5%)      0 (0%)         10m
  kube-system                 aws-node-tbdw7             25m (0%)      0 (0%)      0 (0%)           0 (0%)         10m
  kube-system                 kube-proxy-9dxbt           100m (1%)     0 (0%)      0 (0%)           0 (0%)         10m
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                    Requests       Limits
  --------                    --------       ------
  cpu                         7125m (90%)    0 (0%)
  memory                      10752Mi (37%)  0 (0%)
  ephemeral-storage           0 (0%)         0 (0%)
  hugepages-2Mi               0 (0%)         0 (0%)
  attachable-volumes-aws-ebs  0              0
Events:
  Type     Reason                   Age                From             Message
  ----     ------                   ----               ----             -------
  Normal   RegisteredNode           10m                node-controller  Node ip-192-168-121-67.us-west-2.compute.internal event: Registered Node ip-192-168-121-67.us-west-2.compute.internal in Controller
  Normal   Starting                 10m                kubelet          Starting kubelet.
  Warning  InvalidDiskCapacity      10m                kubelet          invalid capacity 0 on image filesystem       
  Normal   NodeAllocatableEnforced  10m                kubelet          Updated Node Allocatable limit across pods   
  Normal   NodeHasSufficientMemory  10m (x3 over 10m)  kubelet          Node ip-192-168-121-67.us-west-2.compute.internal status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    10m (x3 over 10m)  kubelet          Node ip-192-168-121-67.us-west-2.compute.internal status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     10m (x3 over 10m)  kubelet          Node ip-192-168-121-67.us-west-2.compute.internal status is now: NodeHasSufficientPID
  Normal   Starting                 10m                kube-proxy       Starting kube-proxy.
  Normal   NodeReady                9m38s              kubelet          Node ip-192-168-121-67.us-west-2.compute.internal status is now: NodeReady


Name:               ip-192-168-185-111.us-west-2.compute.internal
Roles:              <none>
Labels:             beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/instance-type=r5.xlarge
                    beta.kubernetes.io/os=linux
                    failure-domain.beta.kubernetes.io/region=us-west-2
                    failure-domain.beta.kubernetes.io/zone=us-west-2d
                    intent=apps
                    k8s.io/cloud-provider-aws=1ca89af3decf1ea3b0004c0db2033941
                    karpenter.k8s.aws/instance-category=r
                    karpenter.k8s.aws/instance-cpu=4
                    karpenter.k8s.aws/instance-family=r5
                    karpenter.k8s.aws/instance-generation=5
                    karpenter.k8s.aws/instance-hypervisor=nitro
                    karpenter.k8s.aws/instance-memory=32768
                    karpenter.k8s.aws/instance-pods=58
                    karpenter.k8s.aws/instance-size=xlarge
                    karpenter.sh/capacity-type=spot
                    karpenter.sh/initialized=true
                    karpenter.sh/provisioner-name=default
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=ip-192-168-185-111.us-west-2.compute.internal
                    kubernetes.io/os=linux
                    node.kubernetes.io/instance-type=r5.xlarge
                    topology.kubernetes.io/region=us-west-2
                    topology.kubernetes.io/zone=us-west-2d
Annotations:        node.alpha.kubernetes.io/ttl: 0
                    volumes.kubernetes.io/controller-managed-attach-detach: true
CreationTimestamp:  Tue, 06 Dec 2022 13:34:32 +0100
Taints:             <none>
Unschedulable:      false
Lease:
  HolderIdentity:  ip-192-168-185-111.us-west-2.compute.internal
  AcquireTime:     <unset>
  RenewTime:       Tue, 06 Dec 2022 14:34:50 +0100
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                
       Message
  ----             ------  -----------------                 ------------------                ------                
       -------
  MemoryPressure   False   Tue, 06 Dec 2022 14:30:36 +0100   Tue, 06 Dec 2022 13:35:02 +0100   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Tue, 06 Dec 2022 14:30:36 +0100   Tue, 06 Dec 2022 13:35:02 +0100   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Tue, 06 Dec 2022 14:30:36 +0100   Tue, 06 Dec 2022 13:35:02 +0100   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Tue, 06 Dec 2022 14:30:36 +0100   Tue, 06 Dec 2022 13:35:22 +0100   KubeletReady          
       kubelet is posting ready status
Addresses:
  InternalIP:   192.168.185.111
  Hostname:     ip-192-168-185-111.us-west-2.compute.internal
  InternalDNS:  ip-192-168-185-111.us-west-2.compute.internal
Capacity:
  attachable-volumes-aws-ebs:  25
  cpu:                         4
  ephemeral-storage:           20959212Ki
  hugepages-1Gi:               0
  hugepages-2Mi:               0
  memory:                      32409624Ki
  pods:                        58
Allocatable:
  attachable-volumes-aws-ebs:  25
  cpu:                         3920m
  ephemeral-storage:           18242267924
  hugepages-1Gi:               0
  hugepages-2Mi:               0
  memory:                      31392792Ki
  pods:                        58
System Info:
  Machine ID:                 ec27a9cae74039c652bed918374586ca
  System UUID:                ec27a9ca-e740-39c6-52be-d918374586ca
  Boot ID:                    d77ceffe-b69e-4cde-be79-15d703c401c6
  Kernel Version:             5.4.219-126.411.amzn2.x86_64
  OS Image:                   Amazon Linux 2
  Operating System:           linux
  Architecture:               amd64
  Container Runtime Version:  containerd://1.6.6
  Kubelet Version:            v1.21.14-eks-fb459a0
  Kube-Proxy Version:         v1.21.14-eks-fb459a0
ProviderID:                   aws:///us-west-2d/i-090e1217164a3b964
Non-terminated Pods:          (5 in total)
  Namespace                   Name                       CPU Requests  CPU Limits  Memory Requests  Memory Limits  Age
  ---------                   ----                       ------------  ----------  ---------------  -------------  ---
  default                     inflate-b9d769f59-9hkl9    1 (25%)       0 (0%)      1536Mi (5%)      0 (0%)         11m
  default                     inflate-b9d769f59-cntbc    1 (25%)       0 (0%)      1536Mi (5%)      0 (0%)         60m
  default                     inflate-b9d769f59-pw5gt    1 (25%)       0 (0%)      1536Mi (5%)      0 (0%)         11m
  kube-system                 aws-node-lvdhq             25m (0%)      0 (0%)      0 (0%)           0 (0%)         60m
  kube-system                 kube-proxy-mhrtm           100m (2%)     0 (0%)      0 (0%)           0 (0%)         60m
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource                    Requests      Limits
  --------                    --------      ------
  cpu                         3125m (79%)   0 (0%)
  memory                      4608Mi (15%)  0 (0%)
  ephemeral-storage           0 (0%)        0 (0%)
  hugepages-1Gi               0 (0%)        0 (0%)
  hugepages-2Mi               0 (0%)        0 (0%)
  attachable-volumes-aws-ebs  0             0
Events:
  Type     Reason                   Age                From             Message
  ----     ------                   ----               ----             -------
  Normal   RegisteredNode           60m                node-controller  Node ip-192-168-185-111.us-west-2.compute.internal event: Registered Node ip-192-168-185-111.us-west-2.compute.internal in Controller
  Normal   Starting                 59m                kubelet          Starting kubelet.
  Warning  InvalidDiskCapacity      59m                kubelet          invalid capacity 0 on image filesystem       
  Normal   NodeHasSufficientMemory  59m (x3 over 59m)  kubelet          Node ip-192-168-185-111.us-west-2.compute.internal status is now: NodeHasSufficientMemory
  Normal   NodeHasNoDiskPressure    59m (x3 over 59m)  kubelet          Node ip-192-168-185-111.us-west-2.compute.internal status is now: NodeHasNoDiskPressure
  Normal   NodeHasSufficientPID     59m (x3 over 59m)  kubelet          Node ip-192-168-185-111.us-west-2.compute.internal status is now: NodeHasSufficientPID
  Normal   NodeAllocatableEnforced  59m                kubelet          Updated Node Allocatable limit across pods   
  Normal   Starting                 59m                kube-proxy       Starting kube-proxy.
  Normal   NodeReady                59m                kubelet          Node ip-192-168-185-111.us-west-2.compute.internal status is now: NodeReady

This time around you’ll see the description for both instances created.


To scale the number of replicas to 0 again:

`kubectl scale deployment inflate --replicas 0`

deployment.apps/inflate scaled


2022-12-06T13:44:41.758Z        INFO    controller.node Added TTL to empty node {"commit": "5d4ae35-dirty", "node": "ip-192-168-121-67.us-west-2.compute.internal"}
2022-12-06T13:44:42.526Z        INFO    controller.node Added TTL to empty node {"commit": "5d4ae35-dirty", "node": "ip-192-168-185-111.us-west-2.compute.internal"}
2022-12-06T13:45:11.001Z        INFO    controller.node Triggering termination after 30s for empty node {"commit": "5d4ae35-dirty", "node": "ip-192-168-121-67.us-west-2.compute.internal"}
2022-12-06T13:45:11.046Z        INFO    controller.termination  Cordoned node   {"commit": "5d4ae35-dirty", "node": "ip-192-168-121-67.us-west-2.compute.internal"}
2022-12-06T13:45:11.256Z        INFO    controller.termination  Deleted node    {"commit": "5d4ae35-dirty", "node": "ip-192-168-121-67.us-west-2.compute.internal"}
2022-12-06T13:45:12.000Z        INFO    controller.node Triggering termination after 30s for empty node {"commit": "5d4ae35-dirty", "node": "ip-192-168-185-111.us-west-2.compute.internal"}
2022-12-06T13:45:12.036Z        INFO    controller.termination  Cordoned node   {"commit": "5d4ae35-dirty", "node": "ip-192-168-185-111.us-west-2.compute.internal"}
2022-12-06T13:45:12.221Z        INFO    controller.termination  Deleted node    {"commit": "5d4ae35-dirty", "node": "ip-192-168-185-111.us-west-2.compute.internal"}

if we run the command `kubectl describe node --selector=intent=apps` 
*see output:*
No resources found in default namespace. 

`kubectl get deployment inflate`
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
inflate   0/0     0            0           104m


The default Provisioner was configured with ttlSecondsAfterEmpty set to 30 seconds. Once the nodes don’t have any pods scheduled on them, Karpenter will terminate the empty nodes using cordon and drain best practices
