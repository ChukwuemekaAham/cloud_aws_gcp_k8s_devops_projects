## CI/CD WITH CODEPIPELINE

[Continuous integration (CI)](https://aws.amazon.com/devops/continuous-integration/) and [continuous delivery (CD)](https://aws.amazon.com/devops/continuous-delivery/) are essential for deft organizations. Teams are more productive when they can make discrete changes frequently, release those changes programmatically and deliver updates without disruption.

In this demo project, I buildt a CI/CD pipeline using [AWS CodePipeline](https://aws.amazon.com/codepipeline/). The CI/CD pipeline deployed a sample Kubernetes service. you can make a change to the GitHub repository and observe the automated delivery of this change to the cluster.

## CREATE IAM ROLE
To use AWS CodeBuild to deploy the sample Kubernetes service in an AWS CodePipeline, it requires an AWS Identity and Access Management (IAM) role capable of interacting with the EKS cluster.

In this step, I created an IAM role and added an inline policy that will be used in the CodeBuild stage to interact with the EKS cluster via kubectl.

Create the role:
```shell
./role.sh
```


**MODIFY AWS-AUTH CONFIGMAP**

After the IAM role has been created; added the role to the aws-auth ConfigMap for the EKS cluster.

Once the ConfigMap includes this new role, kubectl in the CodeBuild stage of the pipeline will be able to interact with the EKS cluster via the IAM role.

```bash
ROLE="    - rolearn: arn:aws:iam::${ACCOUNT_ID}:role/EksCodeBuildKubectlRole\n      username: build\n      groups:\n        - system:masters"

kubectl get -n kube-system configmap/aws-auth -o yaml | awk "/mapRoles: \|/{print;print \"$ROLE\";next}1" > /tmp/aws-auth.yml

kubectl patch configmap/aws-auth -n kube-system --patch "$(cat /tmp/aws-auth.yml)"
```

recommended:  

```bash
eksctl create iamidentitymapping --cluster eks-eksctl-demo  --region=us-east-1 --arn arn:aws:iam::559379197057:role/EksCodeBuildKubectlRole --group system:masters --username admin
```


not recommended; to edit the aws-auth ConfigMap manually, you can run: 

`kubectl edit -n kube-system configmap/aws-auth`


## CLONE SAMPLE REPOSITORY

https://github.com/ChukwuemekaAham/eks-sample-api-service-go

## GITHUB ACCESS TOKEN
In order for CodePipeline to receive callbacks from GitHub, we need to generate a personal access token.

Once created, an access token can be stored in a secure enclave and reused, so this step is only required during the first run or when you need to generate new keys.

Generate one [here](https://github.com/settings/tokens/new) in GitHub.


## CODEPIPELINE SETUP
The AWS CodePipeline can be created using [AWS CloudFormation](https://aws.amazon.com/cloudformation/).

CloudFormation is an [infrastructure as code (IaC)](https://en.wikipedia.org/wiki/Infrastructure_as_Code) tool which provides a common language for you to describe and provision all the infrastructure resources in your cloud environment. CloudFormation allows you to use a simple text file to model and provision, in an automated and secure manner, all the resources needed for your applications across all regions and accounts.

Each EKS deployment/service should have its own CodePipeline and be located in an isolated source repository.

The CloudFormation templates provided with this demo project can be adjusted to meet your system requirements to easily onboard new services to your EKS cluster. For each new service the following steps can be repeated.

Click the Launch button to create the CloudFormation stack in the AWS Management Console.

[Launch](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?stackName=eks-codepipeline&templateURL=https://s3.amazonaws.com/eks-eksctl-demo.com/templates/main/ci-cd-codepipeline.cfn.yml) template CodePipeline & EKS		

After the console is open, enter your GitHub username, personal access token (created in previous step), check the acknowledge box and then click the “Create stack” button located at the bottom of the page.


Wait for the status to change from “CREATE_IN_PROGRESS” to CREATE_COMPLETE before moving on to the next step.

## CloudFormation Stack

Open CodePipeline in the Management Console. You will see a CodePipeline that starts with eks-codepipeline.

On the detail page for the specific CodePipeline, you can see the status along with links to the change and build details.

If you click on the “details” link in the build/deploy stage, you can see the output from the CodeBuild process.


Once the service is built and delivered, we can run the following command to get the Elastic Load Balancer (ELB) endpoint and open it in a browser.

`kubectl describe deployment hello-k8s`

```bash
Name:                   hello-k8s
Namespace:              default
CreationTimestamp:      Mon, 28 Nov 2022 17:50:50 +0100
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=hello-k8s
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  2 max unavailable, 2 max surge
Pod Template:
  Labels:  app=hello-k8s
  Containers:
   hello-k8s:
    Image:        559379197057.dkr.ecr.us-east-1.amazonaws.com/eks-codepipeline-ecrdockerrepository-gx0cpagckbb9:eks-sample-api-service-go.master..2022-11-28.16.50.15.7c2bc4bf
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
NewReplicaSet:   hello-k8s-68444f5cdb (3/3 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  4m46s  deployment-controller  Scaled up replica set hello-k8s-68444f5cdb to 3

```
`kubectl get services hello-k8s -o wide`

```bash
NAME        TYPE           CLUSTER-IP    EXTERNAL-IP                                                               PORT(S)        AGE    SELECTORhello-k8s   LoadBalancer   10.100.142.61   a54abf0f1c3b2482782a697b8fb9e453-1675625062.us-east-1.elb.amazonaws.com   80:31656/TCP   8m5s   app=hello-k8s
```

## TRIGGER NEW RELEASE
Update Our Application

When changes are made to the repository and push to the master branch

The main.go application is compiled, once the build is not accidentally broken

After modification and commit change in GitHub, in approximately one minute a new build will be triggered in the AWS Management ConsoleCodePipeline Running.

Refresh ELB to confirm the update. To retrieve the URL again, use 

`kubectl get services hello-k8s -o wide`

