# AWS Gateway API Controller

[AWS Gateway API Controller](https://www.gateway-api-controller.eks.aws.dev/) lets you connect services across multiple Kubernetes clusters through the Kubernetes [Gateway API](https://gateway-api.sigs.k8s.io/) interface. It is also designed to connect services running on EC2 instances, containers, and as serverless functions. It does this by leveraging [Amazon VPC Lattice](https://aws.amazon.com/vpc/lattice/), which works with Kubernetes Gateway API calls to manage Kubernetes objects.

## Usage

AWS Gateway API Controller can be deployed by enabling the add-on via the following.

```hcl
  enable_aws_gateway_api_controller = true
  aws_gateway_api_controller = {
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
    set = [{
      name  = "clusterVpcId"
      value = "vpc-12345abcd"
    }]
}
```

You can optionally customize the Helm chart that deploys AWS Gateway API Controller via the following configuration.

```hcl
  enable_aws_gateway_api_controller = true
  aws_gateway_api_controller = {
    name                = "aws-gateway-api-controller"
    chart_version       = "v0.0.12"
    repository          = "oci://public.ecr.aws/aws-application-networking-k8s"
    repository_username = data.aws_ecrpublic_authorization_token.token.user_name
    repository_password = data.aws_ecrpublic_authorization_token.token.password
    namespace           = "aws-application-networking-system"
    values              = [templatefile("${path.module}/values.yaml", {})]
    set = [{
      name  = "clusterVpcId"
      value = "vpc-12345abcd"
    }]
  }
```

Verify aws-gateway-api-controller pods are running.

```sh
$ kubectl get pods -n aws-application-networking-system
NAME                                                               READY   STATUS    RESTARTS   AGE
aws-gateway-api-controller-aws-gateway-controller-chart-8f42q426   1/1     Running   0          40s
aws-gateway-api-controller-aws-gateway-controller-chart-8f4tbl9g   1/1     Running   0          71s
```

Deploy example GatewayClass

```sh
$ kubectl apply -f https://raw.githubusercontent.com/aws/aws-application-networking-k8s/main/examples/gatewayclass.yaml
gatewayclass.gateway.networking.k8s.io/amazon-vpc-lattice created
```

Describe GatewayClass

```sh
$ kubectl describe gatewayclass
Name:         amazon-vpc-lattice
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  gateway.networking.k8s.io/v1beta1
Kind:         GatewayClass
Metadata:
  Creation Timestamp:  2023-06-22T22:33:32Z
  Generation:          1
  Resource Version:    819021
  UID:                 aac59195-8f37-4c23-a2a5-b0f363deda77
Spec:
  Controller Name:  application-networking.k8s.aws/gateway-api-controller
Status:
  Conditions:
    Last Transition Time:  2023-06-22T22:33:32Z
    Message:               Accepted
    Observed Generation:   1
    Reason:                Accepted
    Status:                True
    Type:                  Accepted
Events:                    <none>
```
