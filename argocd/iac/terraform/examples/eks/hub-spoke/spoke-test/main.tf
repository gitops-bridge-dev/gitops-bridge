provider "aws" {
  region = local.region
}
data "aws_availability_zones" "available" {}

data "terraform_remote_state" "cluster_hub" {
  backend = "local"

  config = {
    path = "${path.module}/../terraform.tfstate"
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
}

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


locals {
  name = "cluster-spoke-test"
  region = "us-west-2"
  environment = "test"

  enable_cert_manager_addon = true
  enable_aws_load_balancer_controller = true
  addons = {
    enable_metrics_server = true # doesn't required aws resources (ie IAM)
  }

  gitops_workloads_app = templatefile("${path.module}/bootstrap/workloads.yaml",
    {
      environment = local.environment
      cluster = module.eks.cluster_name
    })

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/csantanapr/terraform-gitops-bridge"
  }
}

################################################################################
# GitOps Bridge: Metadata
################################################################################
module "gitops_bridge_metadata" {
  source = "../../../../modules/gitops-bridge-metadata"

  cluster_name = module.eks.cluster_name
  metadata = module.eks_blueprints_addons.gitops_metadata
  environment = local.environment
  addons = local.addons

  enable_argocd = false # we are not deploying argocd to spoke clusters
  options = {
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
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source = "../../../../modules/gitops-bridge-bootstrap"

  providers = {
    kubernetes = kubernetes.hub
  }

  argocd_create_install = false # We are not installing argocd on remote spoke clusters
  argocd_cluster = module.gitops_bridge_metadata.argocd
  argocd_bootstrap_app_of_apps = {
    workloads = local.gitops_workloads_app
  }
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

  enable_cert_manager                 = local.enable_cert_manager_addon
  enable_aws_load_balancer_controller = local.enable_aws_load_balancer_controller

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
  cluster_version                = "1.27"
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
