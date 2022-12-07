# Migrating to Karpenter from Cluster Autoscaler

The aim of this project is to demonstrate how to switch from the Kubernetes Cluster Autoscaler to Karpenter for automatic node provisioning. It is an addon to the following:
- An existing EKS cluster
- An existing VPC and subnets
- An existing security groups
- Nodes are part of one or more node groups
- Workloads have pod disruption budgets that adhere to EKS best practices
- The EKS Cluster has an OIDC provider for service accounts

- aws CLI installed. 

Karpenter additionally requires IAM Roles for Service Accounts (IRSA). IRSA permits Karpenter (within the cluster) to make privileged requests to AWS (as the cloud provider).

## IMPLEMENTING AUTOSCALING WITH KARPENTER

Karpenter automatically launches just the right compute resources to handle the cluster’s applications. It is designed to let cluster-admins take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters.

### EKS

Karpenter’s goal is to improve the efficiency and cost of running workloads on Kubernetes clusters. Karpenter works by:

- Watching for pods that the Kubernetes scheduler has marked as unschedulable
- Evaluating scheduling constraints (resource requests, nodeselectors, affinities, tolerations, and topology spread constraints) requested by the pods
- Provisioning nodes that meet the requirements of the pods
- Removing the nodes when the nodes are no longer needed

Before we install Karpenter, setup the environment.

*RUN:*

```shell
setup.sh
```

## INSTALL KARPENTER
Install Karpenter in clusters with a helm chart and configure a default Provisioner CRD to set the configuration. Karpenter follows best practices for kubernetes controllers for its configuration. Karpenter uses Custom Resource Definition(CRD) to declare its configuration. Custom Resources are extensions of the Kubernetes API. One of the premises of Kubernetes is the declarative aspect of its APIs. Karpenter simplifies its configuration by adhering to that principle.

```shell
install.sh
```

*output:*

```bash
helm upgrade --install --namespace karpenter --create-namespace   karpenter karpenter/karpenter   --set serviceAccoit # for the defaulting webhook to install before creating a ProvisionerRelease 

"karpenter" does not exist. Installing it now. 
NAME: karpenter
LAST DEPLOYED: Mon Dec  5 17:13:38 2022
NAMESPACE: karpenter
STATUS: deployed
REVISION: 1
TEST SUITE: None



kubectl get pod -n karpenter --no-headers | awk '{print $1}' | head -n 1 | xargs kubectl describe pod -n karpenter

Name:                 karpenter-65c8cd57c9-9xx2l
Namespace:            karpenter
Priority:             2000000000
Priority Class Name:  system-cluster-critical
Service Account:      karpenter
Node:                 ip-192-168-34-177.us-west-2.compute.internal/192.168.34.177
Start Time:           Mon, 05 Dec 2022 17:13:59 +0100
Labels:               app.kubernetes.io/instance=karpenter
                      app.kubernetes.io/name=karpenter
                      pod-template-hash=65c8cd57c9
Annotations:          kubernetes.io/psp: eks.privileged
Status:               Running
IP:                   192.168.48.193
IPs:
  IP:           192.168.48.193
Controlled By:  ReplicaSet/karpenter-65c8cd57c9
Containers:
  controller:
    Container ID:   docker://fca3ac436b7debfc5be2db514cb17653a473848e8e0d81438236882cffcc8cc7
    Image:          public.ecr.aws/karpenter/controller:v0.16.3@sha256:68db4f092cf9cc83f5ef9e2fbc5407c2cb682e81f64dfaa700a7602ede38b1cf
    Image ID:       docker-pullable://public.ecr.aws/karpenter/controller@sha256:68db4f092cf9cc83f5ef9e2fbc5407c2cb682e81f64dfaa700a7602ede38b1cf
    Ports:          8080/TCP, 8081/TCP
    Host Ports:     0/TCP, 0/TCP
    State:          Running
      Started:      Mon, 05 Dec 2022 17:14:03 +0100
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     1
      memory:  1Gi
    Requests:
      cpu:      1
      memory:   1Gi
    Liveness:   http-get http://:http/healthz delay=30s timeout=30s period=10s #success=1 #failure=3
    Readiness:  http-get http://:http/readyz delay=0s timeout=30s period=10s #success=1 #failure=3
    Environment:
      CLUSTER_NAME:                  eks-eksctl-demo
      CLUSTER_ENDPOINT:              https://4EF3466DFFDAF745E4605550750BBBC4.gr7.us-west-2.eks.amazonaws.com        
      KARPENTER_SERVICE:             karpenter
      SYSTEM_NAMESPACE:              karpenter (v1:metadata.namespace)
      AWS_DEFAULT_INSTANCE_PROFILE:  KarpenterNodeInstanceProfile-eks-eksctl-demo
      MEMORY_LIMIT:                  1073741824 (limits.memory)
      AWS_DEFAULT_REGION:            us-west-2
      AWS_REGION:                    us-west-2
      AWS_ROLE_ARN:                  arn:aws:iam::263022081217:role/eks-eksctl-demo-karpenter
      AWS_WEB_IDENTITY_TOKEN_FILE:   /var/run/secrets/eks.amazonaws.com/serviceaccount/token
    Mounts:
      /var/run/secrets/eks.amazonaws.com/serviceaccount from aws-iam-token (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-xvsv9 (ro)
  webhook:
    Container ID:  docker://f90f7759b8d7de3e3f2f8aea279ebf83dc2a2598b4bd660011daa5e165db4a48
    Image:         public.ecr.aws/karpenter/webhook:v0.16.3@sha256:96a2d9b06d6bc5127801f358f74b1cf2d289b423a2e9ba40c573c0b14b17dafa
    Image ID:      docker-pullable://public.ecr.aws/karpenter/webhook@sha256:96a2d9b06d6bc5127801f358f74b1cf2d289b423a2e9ba40c573c0b14b17dafa
    Port:          8443/TCP
    Host Port:     0/TCP
    Args:
      -port=8443
    State:          Running
      Started:      Mon, 05 Dec 2022 17:14:05 +0100
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     200m
      memory:  100Mi
    Requests:
      cpu:      200m
      memory:   100Mi
    Liveness:   http-get https://:https-webhook/ delay=30s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get https://:https-webhook/ delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:
      CLUSTER_NAME:                  eks-eksctl-demo
      KUBERNETES_MIN_VERSION:        1.19.0-0
      CLUSTER_ENDPOINT:              https://4EF3466DFFDAF745E4605550750BBBC4.gr7.us-west-2.eks.amazonaws.com        
      KARPENTER_SERVICE:             karpenter
      SYSTEM_NAMESPACE:              karpenter (v1:metadata.namespace)
      MEMORY_LIMIT:                  104857600 (limits.memory)
      AWS_DEFAULT_INSTANCE_PROFILE:  KarpenterNodeInstanceProfile-eks-eksctl-demo
      AWS_DEFAULT_REGION:            us-west-2
      AWS_REGION:                    us-west-2
      AWS_ROLE_ARN:                  arn:aws:iam::263022081217:role/eks-eksctl-demo-karpenter
      AWS_WEB_IDENTITY_TOKEN_FILE:   /var/run/secrets/eks.amazonaws.com/serviceaccount/token
    Mounts:
      /var/run/secrets/eks.amazonaws.com/serviceaccount from aws-iam-token (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-xvsv9 (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  aws-iam-token:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  86400
  kube-api-access-xvsv9:
    Type:                     Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:   3607
    ConfigMapName:            kube-root-ca.crt
    ConfigMapOptional:        <nil>
    DownwardAPI:              true
QoS Class:                    Guaranteed
Node-Selectors:               kubernetes.io/os=linux
Tolerations:                  CriticalAddonsOnly op=Exists
                              node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                              node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Topology Spread Constraints:  topology.kubernetes.io/zone:ScheduleAnyway when max skew 1 is exceeded for selector app.kubernetes.io/instance=karpenter,app.kubernetes.io/name=karpenter
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  9m3s   default-scheduler  Successfully assigned karpenter/karpenter-65c8cd57c9-9xx2l to ip-192-168-34-177.us-west-2.compute.internal
  Normal  Pulling    9m2s   kubelet            Pulling image "public.ecr.aws/karpenter/controller:v0.16.3@sha256:68db4f092cf9cc83f5ef9e2fbc5407c2cb682e81f64dfaa700a7602ede38b1cf"
  Normal  Pulled     9m     kubelet            Successfully pulled image "public.ecr.aws/karpenter/controller:v0.16.3@sha256:68db4f092cf9cc83f5ef9e2fbc5407c2cb682e81f64dfaa700a7602ede38b1cf" in 2.19756432s
  Normal  Created    8m59s  kubelet            Created container controller
  Normal  Started    8m59s  kubelet            Started container controller
  Normal  Pulling    8m59s  kubelet            Pulling image "public.ecr.aws/karpenter/webhook:v0.16.3@sha256:96a2d9b06d6bc5127801f358f74b1cf2d289b423a2e9ba40c573c0b14b17dafa"
  Normal  Pulled     8m57s  kubelet            Successfully pulled image "public.ecr.aws/karpenter/webhook:v0.16.3@sha256:96a2d9b06d6bc5127801f358f74b1cf2d289b423a2e9ba40c573c0b14b17dafa" in 2.564048742s
  Normal  Created    8m57s  kubelet            Created container webhook
  Normal  Started    8m57s  kubelet            Started container webhook
```