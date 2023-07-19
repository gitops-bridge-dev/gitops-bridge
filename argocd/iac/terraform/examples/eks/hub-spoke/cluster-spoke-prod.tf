################################################################################
# GitOps Bridge: Metadata Prod
################################################################################
module "gitops_bridge_metadata_prod" {
  source = "../../../modules/gitops-bridge-metadata"

  cluster_name = module.eks_spoke_prod.cluster_name
  metadata = module.eks_blueprints_addons_spoke_prod.gitops_metadata
  environment = local.cluster_spoke_prod_environment
  addons = local.addons
  enable_argocd = false # we are not deploying argocd to spoke clusters
  options = {
    argocd = {
      server = module.eks_spoke_prod.cluster_endpoint
      argocd_server_config = <<-EOT
        {
          "tlsClientConfig": {
            "insecure": false,
            "caData" : "${module.eks_spoke_prod.cluster_certificate_authority_data}"
          },
          "awsAuthConfig" : {
            "clusterName": "${module.eks_spoke_prod.cluster_name}",
            "roleARN": "${aws_iam_role.spoke_role_prod.arn}"
          }
        }
      EOT
    }
  }
}

################################################################################
# GitOps Bridge: Bootstrap Prod
################################################################################
module "gitops_bridge_bootstrap_prod" {
  source = "../../../modules/gitops-bridge-bootstrap"

  cluster_name = module.eks_spoke_prod.cluster_name
  kubeconfig_command = "KUBECONFIG=${local.kubeconfig} \naws eks --region ${local.region} update-kubeconfig --name ${module.eks_hub.cluster_name}"
  argocd_cluster = module.gitops_bridge_metadata_prod.argocd
  argocd_create_install = false # we are not deploying argocd to spoke clusters
  argocd_create_app_of_apps = false # the hub cluster already has the app of apps
}



################################################################################
# ArgoCD Access to Prod
################################################################################
resource "aws_iam_role" "spoke_role_prod" {
  name               = local.cluster_spoke_prod
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

################################################################################
# Blueprints Addons
################################################################################
module "eks_blueprints_addons_spoke_prod" {
  source = "../../../../../../terraform-aws-eks-blueprints-addons/gitops"

  cluster_name      = module.eks_spoke_prod.cluster_name
  cluster_endpoint  = module.eks_spoke_prod.cluster_endpoint
  cluster_version   = module.eks_spoke_prod.cluster_version
  oidc_provider_arn = module.eks_spoke_prod.oidc_provider_arn
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
module "eks_spoke_prod" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.cluster_spoke_prod
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

/*
  # Team Access
  manage_aws_auth_configmap = true
  aws_auth_roles =[{
      rolearn  = aws_iam_role.spoke_role_prod.arn # Granting access to ArgoCD from hub cluster
      username = "gitops-role"
      groups   = ["system:masters"]
    }]
*/
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
