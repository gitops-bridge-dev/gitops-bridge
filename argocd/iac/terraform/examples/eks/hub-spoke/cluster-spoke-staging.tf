################################################################################
# GitOps Bridge: Metadata Staging
################################################################################
module "gitops_bridge_metadata_staging" {
  source = "../../../modules/gitops-bridge-metadata"

  cluster_name = module.eks_spoke_staging.cluster_name
  metadata = module.eks_blueprints_addons_spoke_staging.gitops_metadata
  environment = local.cluster_spoke_staging_environment
  addons = local.addons
  enable_argocd = false # we are not deploying argocd to spoke clusters
  options = {
    argocd = {
      server = module.eks_spoke_staging.cluster_endpoint
      argocd_server_config = <<-EOT
        {
          "tlsClientConfig": {
            "insecure": false,
            "caData" : "${module.eks_spoke_staging.cluster_certificate_authority_data}"
          },
          "awsAuthConfig" : {
            "clusterName": "${module.eks_spoke_staging.cluster_name}",
            "roleARN": "${aws_iam_role.spoke_role_staging.arn}"
          }
        }
      EOT
    }
  }
}

################################################################################
# GitOps Bridge: Bootstrap Staging
################################################################################
module "gitops_bridge_bootstrap_staging" {
  source = "../../../modules/gitops-bridge-bootstrap"

  options = {
    argocd = {
      cluster_name = module.eks_spoke_staging.cluster_name
      kubeconfig_command = "KUBECONFIG=${local.kubeconfig} \naws eks --region ${local.region} update-kubeconfig --name ${module.eks_hub.cluster_name}"
      argocd_cluster = module.gitops_bridge_metadata_staging.argocd
      argocd_create_install = false # we are not deploying argocd to spoke clusters
      argocd_create_app_of_apps = false # the hub cluster already has the app of apps
    }
  }
  depends_on = [ module.gitops_bridge_bootstrap_hub ]
}

################################################################################
# ArgoCD Access to Prod
################################################################################
resource "aws_iam_role" "spoke_role_staging" {
  name               = local.cluster_spoke_staging
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

################################################################################
# EKS Blueprints Addons
################################################################################
module "eks_blueprints_addons_spoke_staging" {
  source = "github.com/csantanapr/terraform-aws-eks-blueprints-addons?ref=gitops-bridge-v2"

  cluster_name      = module.eks_spoke_staging.cluster_name
  cluster_endpoint  = module.eks_spoke_staging.cluster_endpoint
  cluster_version   = module.eks_spoke_staging.cluster_version
  oidc_provider_arn = module.eks_spoke_staging.oidc_provider_arn
  vpc_id            = module.vpc_staging.vpc_id


  # Using GitOps Bridge
  create_kubernetes_resources    = false

  #enable_aws_efs_csi_driver                    = true
  #enable_aws_fsx_csi_driver                    = true
  #enable_aws_cloudwatch_metrics = true
  #enable_aws_privateca_issuer                  = true
  enable_cert_manager       = true
  #enable_cluster_autoscaler = true
  #enable_external_dns                          = true
  #external_dns_route53_zone_arns = ["arn:aws:route53:::hostedzone/Z123456789"]
  #enable_external_secrets                      = true
  #enable_aws_load_balancer_controller = true
  #enable_aws_for_fluentbit            = true
  #enable_fargate_fluentbit            = true
  #enable_aws_node_termination_handler   = true
  #aws_node_termination_handler_asg_arns = [for asg in module.eks.self_managed_node_groups : asg.autoscaling_group_arn]
  #enable_karpenter = true
  #enable_velero = true
  ## An S3 Bucket ARN is required. This can be declared with or without a Suffix.
  #velero = {
  #  s3_backup_location = "${module.velero_backup_s3_bucket.s3_bucket_arn}/backups"
  #}
  #enable_aws_gateway_api_controller = true

  tags = local.tags
}


################################################################################
# EKS Cluster
################################################################################
# Only required to the aws-auth configmap
provider "kubernetes" {
  host                   = module.eks_spoke_staging.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_spoke_staging.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_spoke_staging.cluster_name]
  }
  alias = "staging"
}

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks_spoke_staging" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  providers = {
    kubernetes = kubernetes.staging
  }

  cluster_name                   = local.cluster_spoke_staging
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true


  vpc_id     = module.vpc_staging.vpc_id
  subnet_ids = module.vpc_staging.private_subnets

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    # Granting access to ArgoCD from hub cluster
    {
      rolearn  = aws_iam_role.spoke_role_staging.arn
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


module "vpc_staging" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.cluster_spoke_staging
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