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
  }

  #needs irsa
  enable_cert_manager       = true
  enable_aws_cloudwatch_metrics = true

  enable_kyverno = true
  enable_argocd                                = true # doesn't required aws resources (ie IAM), only when used as hub-cluster
  enable_argo_rollouts                         = true # doesn't required aws resources (ie IAM)
  enable_argo_workflows                        = true # doesn't required aws resources (ie IAM)
  enable_secrets_store_csi_driver              = true # doesn't required aws resources (ie IAM)
  enable_secrets_store_csi_driver_provider_aws = true # doesn't required aws resources (ie IAM)
  enable_kube_prometheus_stack                 = true # doesn't required aws resources (ie IAM)
  enable_gatekeeper                            = true # doesn't required aws resources (ie IAM)
  enable_ingress_nginx                         = true # doesn't required aws resources (ie IAM)
  enable_metrics_server                        = true # doesn't required aws resources (ie IAM)
  enable_vpa                                   = true # doesn't required aws resources (ie IAM)


  tags = local.tags
}

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


