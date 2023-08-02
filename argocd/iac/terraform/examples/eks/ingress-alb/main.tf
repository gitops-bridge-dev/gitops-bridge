provider "aws" {
  region = local.region
}
data "aws_availability_zones" "available" {}


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

# To get the hosted zone to be use in argocd domain
data "aws_route53_zone" "domain_name" {
  count        = local.enable_ingress ? 1 : 0
  name         = local.domain_name
  private_zone = local.domain_private_zone
}

locals {
  name = "cluster-1-dev"
  region = "us-west-2"

  environment = "dev"

  enable_ingress = true
  domain_private_zone = false
  # change to a valid domain name you created a route53 zone
  # aws route53 create-hosted-zone --name example.com --caller-reference "$(date)"
  domain_name = var.domain_name
  argocd_subdomain  = "argocd"
  argocd_host = "${local.argocd_subdomain}.${local.domain_name}"
  argocd_domain_arn = try(data.aws_route53_zone.domain_name[0].arn, "")

  addons = {
    enable_metrics_server = true # doesn't required aws resources (ie IAM)
  }

  gitops_addons_app = file("${path.module}/bootstrap/addons.yaml")

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
  source = "../../../modules/gitops-bridge-metadata"

  cluster_name = module.eks.cluster_name
  metadata = merge(module.eks_blueprints_addons.gitops_metadata,
  {
    enable_aws_argocd_ingress = true
    metadata_aws_argocd_hosts = "[${local.argocd_host}]"
    metadata_aws_external_dns_domain_filters = "[${local.domain_name}]"
    metadata_aws_argocd_iam_role_arn = ""
    metadata_aws_argocd_namespace = "argocd"
  })
  environment = local.environment
  addons = local.addons
  argocd = {
    enable_argocd = false
  }

}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source = "../../../modules/gitops-bridge-bootstrap"

  argocd_cluster = module.gitops_bridge_metadata.argocd
  argocd_bootstrap_app_of_apps = {
    addons = local.gitops_addons_app
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

  enable_aws_load_balancer_controller = true
  enable_cert_manager            = true
  enable_external_dns            = true
  external_dns_route53_zone_arns = [local.argocd_domain_arn] # ArgoCD Server and UI domain name is registered in Route 53

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

################################################################################
# ACM Certificate
################################################################################

resource "aws_acm_certificate" "cert" {
  count             = local.enable_ingress ? 1 : 0
  domain_name       = "*.${local.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert" {
  count           = local.enable_ingress ? 1 : 0
  zone_id         = data.aws_route53_zone.domain_name[0].zone_id
  name            = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_name
  type            = tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_type
  records         = [tolist(aws_acm_certificate.cert[0].domain_validation_options)[0].resource_record_value]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "cert" {
  count                   = local.enable_ingress ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert : record.fqdn]
}