# Helm Release Add-ons

Starting with [EKS Blueprints v5](https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/main/docs/v4-to-v5/motivation.md) we have made a decision to only support the provisioning of a certain core set of [add-ons](./addons/). On an going basis, we will evaluate the current list to see if more add-ons need to be supported via this repo. Typically you can expect that any AWS created add-on that is not yet available via the [Amazon EKS add-ons](./amazon-eks-addons.md) will be prioritized to be provisioned through this repository.

In addition to these AWS add-ons, we will also support the provisioning of certain OSS add-ons that we think customers will benefit from. These are selected based on customer demand (e.g. [metrics-server](./addons/metrics-server.md)) and certain patterns ([gitops](./addons/argocd.md)) that are foundational elements for a complete blueprint of an EKS cluster.

One of the reasons customers pick Kubernetes is because of its strong commercial and open-source software ecosystem and would like to provision add-ons that are not necessarily supported by EKS Blueprints. For such add-ons the options are as following:

## With `helm_release` Terraform Resource

The [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) resource is the most fundamental way to provision a helm chart via Terraform.

Use this resource, if you need to control the lifecycle add-ons down to level of each add-on resource.

## With `helm_releases` Variable

You can use the `helm_releases` variable in [EKS Blueprints Add-ons](https://registry.terraform.io/modules/aws-ia/eks-blueprints-addons/aws/latest?tab=inputs) to provide a map of add-ons and their respective Helm configuration. Under the hood, we just iterate through the provided map and pass each configuration to the Terraform [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) resource.

E.g.

```hcl
module "addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = "<cluster_name>"
  cluster_endpoint  = "<cluster_endpoint>"
  cluster_version   = "<cluster_version>"
  oidc_provider_arn = "<oidc_provider_arn>"

  # EKS add-ons
  eks_addons = {
    coredns = {}
    vpc-cni = {}
    kube-proxy = {}
  }

  # Blueprints add-ons
  enable_aws_efs_csi_driver                    = true
  enable_aws_cloudwatch_metrics                = true
  enable_cert_manager                          = true
  ...

  # Pass in any number of Helm charts to be created for those that are not natively supported
  helm_releases = {
    prometheus-adapter = {
      description      = "A Helm chart for k8s prometheus adapter"
      namespace        = "prometheus-adapter"
      create_namespace = true
      chart            = "prometheus-adapter"
      chart_version    = "4.2.0"
      repository       = "https://prometheus-community.github.io/helm-charts"
      values = [
        <<-EOT
          replicas: 2
          podDisruptionBudget:
            enabled: true
        EOT
      ]
    }
    gpu-operator = {
      description      = "A Helm chart for NVIDIA GPU operator"
      namespace        = "gpu-operator"
      create_namespace = true
      chart            = "gpu-operator"
      chart_version    = "v23.3.2"
      repository       = "https://nvidia.github.io/gpu-operator"
      values = [
        <<-EOT
          operator:
            defaultRuntime: containerd
        EOT
      ]
    }
  }

  tags = local.tags
}
```

With this pattern, the lifecycle of all your add-ons is tied to that of the `addons` module. This allows you to easily target the addon module in your Terraform apply and destroy commands. E.g.

```sh
terraform apply -target=module.addons

terraform destroy -target=module.addons
```

## With EKS Blueprints Addon Module

If you have an add-on that requires an IAM Role for Service Account (IRSA), we have created a new Terraform module [terraform-aws-eks-blueprints-addon](https://registry.terraform.io/modules/aws-ia/eks-blueprints-addon/aws/latest) that can help provision a Helm chart along with an IAM role and policies with permissions required for the add-on to function properly. We use this module for all of the add-ons that are provisioned by EKS Blueprints Add-ons today.

You can optionally use this module for add-ons that do not need IRSA or even just to create the IAM resources for IRSA and skip the helm release. Detailed usage of how to consume this module can be found in its [readme](https://github.com/aws-ia/terraform-aws-eks-blueprints-addon#readme).

This pattern can be used to create a Terraform module with a set of add-ons that are not supported in the EKS Blueprints Add-ons today and wrap them in the same module definition. An example of this is the [ACK add-ons repository](https://github.com/aws-ia/terraform-aws-eks-ack-addons) which is a collection of ACK helm chart deployments with IRSA for each of the ACK controllers.
