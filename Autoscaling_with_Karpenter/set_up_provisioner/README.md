## SETTING UP THE PROVISIONER
Setting up a simple (default) CRD Provisioner
Karpenter configuration comes in the form of a Provisioner CRD (Custom Resource Definition). A single Karpenter provisioner is capable of handling many different pod shapes. Karpenter makes scheduling and provisioning decisions based on pod attributes such as labels and affinity. A cluster may have more than one Provisioner, but for the moment we will declare just one: the default Provisioner.

**One of the main objectives of Karpenter is to simplify the management of capacity.**

If you are familiar with other Auto Scalers, you will notice Karpenter takes a different approach. You may have heard the approached referred as *group-less auto scaling*. Other Solutions have traditionally used the concept of a node group as the element of control that defines the characteristics of the capacity provided (i.e: On-Demand, EC2 Spot, GPU Nodes, etc) and that controls the desired scale of the group in the cluster. In AWS the implementation of a node group matches with Auto Scaling groups. Over time, clusters using this paradigm, that run different type of applications requiring different capacity types, end up with a *complex configuration* and operational model where node groups must be defined and provided in advance.

Deploy the following configuration:

`kubectl apply -f provisioner.yaml`

*output:*
provisioner.karpenter.sh/default created
awsnodetemplate.karpenter.k8s.aws/default created

The configuration for the provider is split into two parts. The first one defines the provisioner relevant spec. The second part is defined by the provider implementation, in our case **AWSNodeTemplate** and defines the specific configuration that applies to that cloud provider. We focus in a few of the settings used.

**Requirements Section:** The Provisioner CRD supports defining node properties like instance type and zone. For example, in response to a label of topology.kubernetes.io/zone=us-west-1b, Karpenter will provision nodes in that availability zone. In this project I set the *karpenter.sh/capacity-type* to procure EC2 Spot instances, and *karpenter.k8s.aws/instance-size* to avoid smaller instances. You can learn which other properties are available [here](https://karpenter.sh/v0.16.0/tasks/scheduling/#selecting-nodes). 

**Limits section:** Provisioners can define a limit in the number of CPU’s and memory allocated to that particular provisioner and part of the cluster.

**Provider section:** This provisioner uses securityGroupSelector and subnetSelector to discover resources used to launch nodes. It uses the tags that Karpenter attached to the subnets.

**ttlSecondsAfterEmpty:** value configures Karpenter to terminate empty nodes. This behavior can be disabled by leaving the value undefined. In this case it is set to a value of 30secs for a quick demonstration.

**ttlSecondsUntilExpired:** optional parameter. When set it defines when a node will be deleted. This is useful to force new nodes with up to date AMI’s. The value is set to 30 days.

**Tags:** Provisioners can also define a set of tags that the EC2 instances will have upon creation. This helps to enable accounting and governance at the EC2 level. This is done through as part of the provider section.
Karpenter has been designed to be generic and support other Cloud and Infrastructure providers. You can read more about the configuration available for the AWS Provisioner here

### Displaying Karpenter Logs
A new terminal window is opened to leave the command below running so I can come back to that terminal every time I want insight from the karpenter console log.

`kubectl logs -f deployment/karpenter -n karpenter controller`

*output:*

```bash
Found 2 pods, using pod/karpenter-65c8cd57c9-9xx2l
2022-12-05T16:14:03.270Z        DEBUG   Successfully created the logger.
2022-12-05T16:14:03.270Z        DEBUG   Logging level set to: debug
2022-12-05T16:14:03.275Z        INFO    controller      Initializing with version v0.16.3       {"commit": "5d4ae35-dirty"}
2022-12-05T16:14:03.275Z        INFO    controller      Setting GC memory limit to 966367641, container limit = 1073741824   {"commit": "5d4ae35-dirty"}
{"level":"info","ts":1670256843.2754443,"logger":"fallback","caller":"injection/injection.go:61","msg":"Starting informers..."}
2022-12-05T16:14:03.297Z        DEBUG   controller.aws  Using AWS region us-west-2      {"commit": "5d4ae35-dirty"}  
2022-12-05T16:14:03.487Z        DEBUG   controller.aws  Discovered caBundle, length 1066        {"commit": "5d4ae35-dirty"}
2022-12-05T16:14:03.487Z        INFO    controller      loading config from karpenter/karpenter-global-settings {"commit": "5d4ae35-dirty"}
2022-12-05T16:14:03.595Z        INFO    controller      Starting server {"commit": "5d4ae35-dirty", "path": "/metrics", "kind": "metrics", "addr": "[::]:8080"}
2022-12-05T16:14:03.595Z        INFO    controller      Starting server {"commit": "5d4ae35-dirty", "kind": "health probe", "addr": "[::]:8081"}
I1205 16:14:03.696395       1 leaderelection.go:248] attempting to acquire leader lease karpenter/karpenter-leader-election...
I1205 16:14:03.764984       1 leaderelection.go:258] successfully acquired lease karpenter/karpenter-leader-election 
2022-12-05T16:14:03.781Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "provisioning", "controllerGroup": "", "controllerKind": "Pod", "source": "kind source: *v1.Pod"}
2022-12-05T16:14:03.781Z        INFO    controller      Starting Controller     {"commit": "5d4ae35-dirty", "controller": "provisioning", "controllerGroup": "", "controllerKind": "Pod"}
2022-12-05T16:14:03.781Z        INFO    controller      Starting workers        {"commit": "5d4ae35-dirty", "controller": "provisioning", "controllerGroup": "", "controllerKind": "Pod", "worker count": 10}
2022-12-05T16:14:03.782Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "pod-state", "controllerGroup": "", "controllerKind": "Pod", "source": "kind source: *v1.Pod"}
2022-12-05T16:14:03.783Z        INFO    controller      Starting Controller     {"commit": "5d4ae35-dirty", "controller": "pod-state", "controllerGroup": "", "controllerKind": "Pod"}
2022-12-05T16:14:03.783Z        INFO    controller      Starting workers        {"commit": "5d4ae35-dirty", "controller": "pod-state", "controllerGroup": "", "controllerKind": "Pod", "worker count": 10}
2022-12-05T16:14:03.784Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "node-state", "controllerGroup": "", "controllerKind": "Node", "source": "kind source: *v1.Node"}
2022-12-05T16:14:03.784Z        INFO    controller      Starting Controller     {"commit": "5d4ae35-dirty", "controller": "node-state", "controllerGroup": "", "controllerKind": "Node"}
2022-12-05T16:14:03.785Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "node", "controllerGroup": "", "controllerKind": "Node", "source": "kind source: *v1.Node"}
2022-12-05T16:14:03.785Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "node", "controllerGroup": "", "controllerKind": "Node", "source": "kind source: *v1alpha5.Provisioner"}        
2022-12-05T16:14:03.785Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "node", "controllerGroup": "", "controllerKind": "Node", "source": "kind source: *v1.Pod"}
2022-12-05T16:14:03.785Z        INFO    controller      Starting Controller     {"commit": "5d4ae35-dirty", "controller": "node", "controllerGroup": "", "controllerKind": "Node"}
2022-12-05T16:14:03.787Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "provisioner-state", "controllerGroup": "karpenter.sh", "controllerKind": "Provisioner", "source": "kind source: *v1alpha5.Provisioner"}
2022-12-05T16:14:03.787Z        INFO    controller      Starting Controller     {"commit": "5d4ae35-dirty", "controller": "provisioner-state", "controllerGroup": "karpenter.sh", "controllerKind": "Provisioner"}
2022-12-05T16:14:03.788Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "podmetrics", "controllerGroup": "", "controllerKind": "Pod", "source": "kind source: *v1.Pod"}
2022-12-05T16:14:03.788Z        INFO    controller      Starting Controller     {"commit": "5d4ae35-dirty", "controller": "podmetrics", "controllerGroup": "", "controllerKind": "Pod"}
2022-12-05T16:14:03.788Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "termination", "controllerGroup": "", "controllerKind": "Node", "source": "kind source: *v1.Node"}
2022-12-05T16:14:03.788Z        INFO    controller      Starting Controller     {"commit": "5d4ae35-dirty", "controller": "termination", "controllerGroup": "", "controllerKind": "Node"}
2022-12-05T16:14:03.789Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "counter", "controllerGroup": "karpenter.sh", "controllerKind": "Provisioner", "source": "kind source: *v1alpha5.Provisioner"}
2022-12-05T16:14:03.789Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "counter", "controllerGroup": "karpenter.sh", "controllerKind": "Provisioner", "source": "kind source: *v1.Node"}
2022-12-05T16:14:03.789Z        INFO    controller      Starting Controller     {"commit": "5d4ae35-dirty", "controller": "counter", "controllerGroup": "karpenter.sh", "controllerKind": "Provisioner"}
2022-12-05T16:14:03.792Z        INFO    controller      Starting EventSource    {"commit": "5d4ae35-dirty", "controller": "provisionermetrics", "controllerGroup": "karpenter.sh", "controllerKind": "Provisioner", "source": "kind source: *v1alpha5.Provisioner"}
2022-12-05T16:14:03.792Z        INFO    controller      Starting Controller     {"commit": "5d4ae35-dirty", "controller": "provisionermetrics", "controllerGroup": "karpenter.sh", "controllerKind": "Provisioner"}
2022-12-05T16:14:03.793Z        DEBUG   controller.aws.launchtemplate   Hydrating the launch template cache with tags matching "karpenter.k8s.aws/cluster: eks-eksctl-demo"  {"commit": "5d4ae35-dirty"}
2022-12-05T16:14:03.883Z        DEBUG   controller.aws.launchtemplate   Finished hydrating the launch template cache with 0 items    {"commit": "5d4ae35-dirty"}
2022-12-05T16:14:03.889Z        INFO    controller      Starting workers        {"commit": "5d4ae35-dirty", "controller": "node-state", "controllerGroup": "", "controllerKind": "Node", "worker count": 10}
2022-12-05T16:14:03.889Z        INFO    controller      Starting workers        {"commit": "5d4ae35-dirty", "controller": "podmetrics", "controllerGroup": "", "controllerKind": "Pod", "worker count": 1}
2022-12-05T16:14:03.990Z        INFO    controller      Starting workers        {"commit": "5d4ae35-dirty", "controller": "provisioner-state", "controllerGroup": "karpenter.sh", "controllerKind": "Provisioner", "worker count": 10}    
2022-12-05T16:14:04.002Z        INFO    controller      Starting workers        {"commit": "5d4ae35-dirty", "controller": "counter", "controllerGroup": "karpenter.sh", "controllerKind": "Provisioner", "worker count": 10}
2022-12-05T16:14:04.022Z        INFO    controller      Starting workers        {"commit": "5d4ae35-dirty", "controller": "node", "controllerGroup": "", "controllerKind": "Node", "worker count": 10}
2022-12-05T16:14:04.023Z        INFO    controller      Starting workers        {"commit": "5d4ae35-dirty", "controller": "termination", "controllerGroup": "", "controllerKind": "Node", "worker count": 10}
2022-12-05T16:14:04.023Z        INFO    controller      Starting workers        {"commit": "5d4ae35-dirty", "controller": "provisionermetrics", "controllerGroup": "karpenter.sh", "controllerKind": "Provisioner", "worker count": 1}    
2022-12-05T16:14:04.190Z        INFO    controller.aws.pricing  updated spot pricing with 587 instance types and 2013 offerings      {"commit": "5d4ae35-dirty"}
2022-12-05T16:14:06.199Z        INFO    controller.aws.pricing  updated on-demand pricing with 588 instance types    
        {"commit": "5d4ae35-dirty"}
2022-12-06T11:52:08.516Z        ERROR   controller.consolidation        consolidating cluster, determining candidate nodes, listing instance types for default, getting providerRef, AWSNodeTemplate.karpenter.k8s.aws "default" not found        {"commit": "5d4ae35-dirty"}
2022-12-06T11:52:19.665Z        DEBUG   controller.consolidation        Discovered 580 EC2 instance types       {"commit": "5d4ae35-dirty"}
2022-12-06T11:52:19.747Z        DEBUG   controller.consolidation        Discovered subnets: [subnet-02c00795c8ff25fa0 (us-west-2c) subnet-0653d0792de27f2a0 (us-west-2d) subnet-0f43e8d7921067456 (us-west-2b) subnet-043c232853e0081e7 (us-west-2b) subnet-05338912e45e09691 (us-west-2c) subnet-063b2f5f780f33c2f (us-west-2d)] {"commit": "5d4ae35-dirty"}  
2022-12-06T11:52:19.912Z        DEBUG   controller.consolidation        Discovered EC2 instance types zonal offerings for subnets {"alpha.eksctl.io/cluster-name":"eks-eksctl-demo"} {"commit": "5d4ae35-dirty"}
```

Karpenter log configuration is stored as a Kubernetes ConfigMap. The configuration can be read by running the following command: 

`kubectl describe configmap config-logging -n karpenter`. 

*output:*

Name:         config-logging
Namespace:    karpenter
Labels:       app.kubernetes.io/instance=karpenter
              app.kubernetes.io/managed-by=Helm
              app.kubernetes.io/name=karpenter
              app.kubernetes.io/version=0.16.3
              helm.sh/chart=karpenter-0.16.3
Annotations:  meta.helm.sh/release-name: karpenter
              meta.helm.sh/release-namespace: karpenter

Data
====
zap-logger-config:
----
{
  "level": "debug",
  "development": false,
  "disableStacktrace": true,
  "disableCaller": true,
  "sampling": {
    "initial": 100,
    "thereafter": 100
  },
  "outputPaths": ["stdout"],
  "errorOutputPaths": ["stderr"],
  "encoding": "console",
  "encoderConfig": {
    "timeKey": "time",
    "levelKey": "level",
    "nameKey": "logger",
    "callerKey": "caller",
    "messageKey": "message",
    "stacktraceKey": "stacktrace",
    "levelEncoder": "capital",
    "timeEncoder": "iso8601"
  }
}


BinaryData
====

Events:  <none>

Increase the logging level to debug using the following command: 

`kubectl patch configmap config-logging -n karpenter --patch '{"data":{"loglevel.controller":"debug"}}'`