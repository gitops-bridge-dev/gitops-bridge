
################################################################################
# GitOps Bridge: Metadata Hub
################################################################################
module "gitops_bridge_metadata_hub" {
  source = "../../../modules/gitops-bridge-metadata"

  cluster_name = module.eks_hub.cluster_name
  metadata = merge(module.eks_blueprints_addons_hub.gitops_metadata,{
    aws_enable_argocd = true,
    metadata_aws_argocd_iam_role_arn = module.argocd_irsa.iam_role_arn,
    metadata_aws_argocd_namespace = "argocd"
  })
  environment = local.cluster_hub_environment
  addons = local.addons
  enable_argocd = false # we are going to install argocd with aws irsa
}

################################################################################
# GitOps Bridge: Bootstrap Hub
################################################################################
locals {
  kubeconfig = "/tmp/${module.eks_hub.cluster_name}"
  argocd_bootstrap_control_plane = "https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap/control-plane/exclude/bootstrap.yaml"
  argocd_bootstrap_workloads = "https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap/workloads/exclude/bootstrap.yaml"
}
module "gitops_bridge_bootstrap_hub" {
  source = "../../../modules/gitops-bridge-bootstrap"

  cluster_name = module.eks_hub.cluster_name
  kubeconfig_command = "KUBECONFIG=${local.kubeconfig} \naws eks --region ${local.region} update-kubeconfig --name ${module.eks_hub.cluster_name}"
  argocd_cluster = module.gitops_bridge_metadata_hub.argocd
  argocd_bootstrap_app_of_apps = [
    "argocd app create --port-forward -f ${local.argocd_bootstrap_control_plane}",
    "argocd app create --port-forward -f ${local.argocd_bootstrap_workloads}"
  ]
}

################################################################################
# ArgoCD EKS Access
################################################################################

module "argocd_irsa" {
  source = "aws-ia/eks-blueprints-addon/aws"

  create_release             = false
  create_role                = true
  role_name_use_prefix       = false
  role_name                  = "${module.eks_hub.cluster_name}-argocd-hub"
  assume_role_condition_test = "StringLike"
  create_policy = false
  role_policies = {
    ArgoCD_EKS_Policy = aws_iam_policy.irsa_policy.arn
  }
  oidc_providers = {
    this = {
      provider_arn    = module.eks_hub.oidc_provider_arn
      namespace       = "argocd"
      service_account = "argocd-*"
    }
  }
  tags = local.tags

}

resource "aws_iam_policy" "irsa_policy" {
  name        = "${module.eks_hub.cluster_name}-argocd-irsa"
  description = "IAM Policy for ArgoCD Hub"
  policy      = data.aws_iam_policy_document.irsa_policy.json
  tags        = local.tags
}

data "aws_iam_policy_document" "irsa_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [module.argocd_irsa.iam_role_arn]
    }
  }
}

################################################################################
# Blueprints Addons
################################################################################
module "eks_blueprints_addons_hub" {
  source = "../../../../../../terraform-aws-eks-blueprints-addons/gitops"

  cluster_name      = module.eks_hub.cluster_name
  cluster_endpoint  = module.eks_hub.cluster_endpoint
  cluster_version   = module.eks_hub.cluster_version
  oidc_provider_arn = module.eks_hub.oidc_provider_arn
  vpc_id            = module.vpc.vpc_id


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
# Cluster
################################################################################
#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks_hub" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.cluster_hub
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
