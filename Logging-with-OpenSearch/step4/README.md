### DEPLOY FLUENT BIT

Let’s start by downloading the fluentbit.yaml deployment file and replace some variables.

```bash
cd ~/environment/logging

#get the Amazon OpenSearch Endpoint

export ES_ENDPOINT=$(aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --output text --query "DomainStatus.Endpoint")


echo ${ES_ENDPOINT}
# search-eks-logging-heorfc6pzueheghqboedk3vzca.us-west-2.es.amazonaws.com


# The fluent bit log agent configuration is located in the Kubernetes
# ConfigMap and will be deployed as a DaemonSet, i.e. one pod per worker
# node. In this case, a 3 node cluster is used and so 3 pods will be 
# shown in the output when deployed.

`kubectl apply -f ~/environment/logging/fluentbit.yaml`

# *output:*

# clusterrole.rbac.authorization.k8s.io/fluent-bit-read created
# clusterrolebinding.rbac.authorization.k8s.io/fluent-bit-read created
# configmap/fluent-bit-config created
# daemonset.apps/fluent-bit created

#Wait for all of the pods to change to running status

`kubectl --namespace=logging get pods`

# *output:*

# NAME               READY   STATUS    RESTARTS   AGE
# fluent-bit-5wx57   1/1     Running   0          81s
# fluent-bit-7cwnn   1/1     Running   0          81s
# fluent-bit-g25hv   1/1     Running   0          81s

```