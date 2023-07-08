################################################################################
# Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source = "../../../../../terraform-aws-eks-blueprints-addons/gitops"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
    coredns = {
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {}
  }

  enable_aws_efs_csi_driver                    = true
  enable_aws_fsx_csi_driver                    = true
  #enable_argocd                                = true # doesn't required aws resources (ie IAM), only when used as hub-cluster
  #enable_argo_rollouts                         = true # doesn't required aws resources (ie IAM)
  #enable_argo_workflows                        = true # doesn't required aws resources (ie IAM)
  enable_aws_cloudwatch_metrics = true
  enable_aws_privateca_issuer                  = true
  enable_cert_manager       = true
  enable_cluster_autoscaler = true
  #enable_secrets_store_csi_driver              = true # doesn't required aws resources (ie IAM)
  #enable_secrets_store_csi_driver_provider_aws = true # doesn't required aws resources (ie IAM)
  #enable_kube_prometheus_stack                 = true # doesn't required aws resources (ie IAM)
  enable_external_dns                          = true
  #external_dns_route53_zone_arns = [data.aws_route53_zone.domain_name.arn]
  external_dns_route53_zone_arns = ["arn:aws:route53:::hostedzone/Z123456789"]
  enable_external_secrets                      = true
  #enable_gatekeeper                           = true # doesn't required aws resources (ie IAM)
  #enable_ingress_nginx                = true # doesn't required aws resources (ie IAM)
  enable_aws_load_balancer_controller = true
  #enable_metrics_server               = true # doesn't required aws resources (ie IAM)
  #enable_vpa                          = true # doesn't required aws resources (ie IAM)
  enable_aws_for_fluentbit            = true
  aws_for_fluentbit_cw_log_group = {
    use_name_prefix = true
    name_prefix = "/aws/eks/${module.eks.cluster_name}/aws-fluentbit-logs"
  }
  #enable_fargate_fluentbit            = true # doesn't required aws resources (ie IAM)

  enable_aws_node_termination_handler   = true
  aws_node_termination_handler_asg_arns = [for asg in module.eks.self_managed_node_groups : asg.autoscaling_group_arn]

  #enable_karpenter = true
  # ECR login required
  #karpenter = {
  #  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  #  repository_password = data.aws_ecrpublic_authorization_token.token.password
  #}

  #enable_velero = true
  ## An S3 Bucket ARN is required. This can be declared with or without a Prefix.
  #velero = {
  #  s3_backup_location = "${module.velero_backup_s3_bucket.s3_bucket_arn}/backups"
  #}


  tags = local.tags
}

/*
data "aws_route53_zone" "domain_name" {
  name         = "example.com"
  private_zone = false
}
*/

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.14"

  role_name_prefix = "${local.name}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

