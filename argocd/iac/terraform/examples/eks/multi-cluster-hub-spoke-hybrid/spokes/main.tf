provider "aws" {
  region = local.region
}
data "aws_availability_zones" "available" {}

################################################################################
# Kubernetes Access for Spoke Cluster
################################################################################

data "terraform_remote_state" "cluster_hub" {
  backend = "local"

  config = {
    path = "${path.module}/../hub/terraform.tfstate"
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.cluster_hub.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster_hub.outputs.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.cluster_hub.outputs.cluster_name, "--region", data.terraform_remote_state.cluster_hub.outputs.cluster_region]
  }
  alias = "hub"
}

provider "kubectl" {
  host                   = data.terraform_remote_state.cluster_hub.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster_hub.outputs.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.cluster_hub.outputs.cluster_name, "--region", data.terraform_remote_state.cluster_hub.outputs.cluster_region]
    command     = "aws"
  }
  load_config_file       = false
  apply_retry_count      = 15
  alias = "hub"
}

################################################################################
# Kubernetes Access for Spoke Cluster
################################################################################

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
    command     = "aws"
  }
  load_config_file       = false
  apply_retry_count      = 15
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
    }
  }
}



locals {
  name = "cluster-${terraform.workspace}"
  environment = terraform.workspace
  region = "us-west-2"

  vpc_cidr = var.vpc_cidr
  kubernetes_version = var.kubernetes_version

  addons = {
    enable_metrics_server = true # doesn't required aws resources (ie IAM)
  }

  argocd_bootstrap_app_of_apps = {
    workloads = templatefile("${path.module}/bootstrap/workloads.yaml",
    {
      environment = local.environment
      cluster = module.eks.cluster_name
    })
  }

  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/csantanapr/terraform-gitops-bridge"
  }
}

################################################################################
# GitOps Bridge: Metadata for Spoke Cluster
################################################################################
module "gitops_bridge_metadata_spoke" {
  source = "../../../../modules/gitops-bridge-metadata"

  cluster_name = module.eks.cluster_name
  environment = local.environment
  #No metadata
  addons = {
    enable_argocd = false # ArgoCD is deploy from Hub Cluster
  }
}

################################################################################
# GitOps Bridge: Bootstrap for Spoke Cluster
################################################################################
# Wait ArgoCD CRDs and "argocd" namespace to be created by hub cluster to this spoke cluster
resource "time_sleep" "wait_for_argocd_namespace_and_crds" {
  create_duration = "7m"

  depends_on = [module.gitops_bridge_bootstrap_hub]
}
module "gitops_bridge_bootstrap_spoke" {
  source = "../../../../modules/gitops-bridge-bootstrap"

  argocd_cluster = module.gitops_bridge_metadata_spoke.argocd
  argocd_bootstrap_app_of_apps = local.argocd_bootstrap_app_of_apps
  argocd_create_install = false # Not installing argocd via helm on spoke cluster

  depends_on = [ time_sleep.wait_for_argocd_namespace_and_crds ]
}


################################################################################
# GitOps Bridge: Metadata for Hub Cluster
################################################################################
module "gitops_bridge_metadata_hub" {
  source = "../../../../modules/gitops-bridge-metadata"

  cluster_name = module.eks.cluster_name
  metadata = module.eks_blueprints_addons.gitops_metadata
  environment = local.environment
  addons = local.addons

  argocd = {
    server = module.eks.cluster_endpoint
    argocd_server_config = <<-EOT
      {
        "tlsClientConfig": {
          "insecure": false,
          "caData" : "${module.eks.cluster_certificate_authority_data}"
        },
        "awsAuthConfig" : {
          "clusterName": "${module.eks.cluster_name}",
          "roleARN": "${aws_iam_role.spoke.arn}"
        }
      }
    EOT
  }

}

################################################################################
# GitOps Bridge: Bootstrap for Hub Cluster
################################################################################
module "gitops_bridge_bootstrap_hub" {
  source = "../../../../modules/gitops-bridge-bootstrap"

  # The ArgoCD remote cluster secret is deploy on hub cluster and spoke clusters
  providers = {
    kubernetes = kubernetes.hub
    kubectl = kubectl.hub
  }

  argocd_create_install = false # We are not installing argocd on remote spoke clusters
  argocd_cluster = module.gitops_bridge_metadata_hub.argocd

}

################################################################################
# ArgoCD EKS Access
################################################################################
resource "aws_iam_role" "spoke" {
  name               = "${module.eks.cluster_name}-argocd-spoke"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.terraform_remote_state.cluster_hub.outputs.argocd_iam_role_arn]
    }
  }
}


################################################################################
# EKS Blueprints Addons
################################################################################
module "eks_blueprints_addons" {
  source = "github.com/csantanapr/terraform-aws-eks-blueprints-addons?ref=gitops-bridge-v2"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id            = module.vpc.vpc_id

  # Using GitOps Bridge
  create_kubernetes_resources    = false

  enable_cert_manager                 = true
  enable_aws_load_balancer_controller = true

  tags = local.tags
}

################################################################################
# EKS Cluster
################################################################################
#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.name
  cluster_version                = local.kubernetes_version
  cluster_endpoint_public_access = true


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    # Granting access to ArgoCD from hub cluster
    {
      rolearn  = aws_iam_role.spoke.arn
      username = "gitops-role"
      groups = [
        "system:masters"
      ]
    },
  ]

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.medium"]

      min_size     = 3
      max_size     = 10
      desired_size = 3
    }
  }
  # EKS Addons
  cluster_addons = {
    vpc-cni = {
      # Specify the VPC CNI addon should be deployed before compute to ensure
      # the addon is configured before data plane compute resources are created
      # See README for further details
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }
  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
