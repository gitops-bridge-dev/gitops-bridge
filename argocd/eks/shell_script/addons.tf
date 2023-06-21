# Required for public ECR where Karpenter artifacts are hosted
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}


################################################################################
# Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source = "../../../terraform-aws-eks-blueprints-addons/"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  argocd_manage_add_ons = true

  # enable_aws_efs_csi_driver                    = true
  # enable_aws_fsx_csi_driver                    = true
  #enable_argocd                                = true # doesn't required aws resources (ie IAM), only when used as hub-cluster
  #enable_argo_rollouts                         = true # doesn't required aws resources (ie IAM)
  #enable_argo_workflows                        = true # doesn't required aws resources (ie IAM)
  enable_aws_cloudwatch_metrics                = true
  #enable_aws_privateca_issuer                  = true
  enable_cert_manager                          = true
  enable_cluster_autoscaler                    = true
  #enable_secrets_store_csi_driver              = true
  #enable_secrets_store_csi_driver_provider_aws = true
  #enable_kube_prometheus_stack                 = true
  #enable_external_dns                          = true
  #enable_external_secrets                      = true
  # enable_gatekeeper                            = true
  #enable_ingress_nginx                = true # doesn't required aws resources (ie IAM)
  #enable_aws_load_balancer_controller = true
  #enable_metrics_server               = true # doesn't required aws resources (ie IAM)
  #enable_vpa                          = true
  #enable_aws_for_fluentbit            = true
  #enable_fargate_fluentbit            = true # doesn't required aws resources (ie IAM)

  #enable_aws_node_termination_handler   = true
  #aws_node_termination_handler_asg_arns = [for asg in module.eks.self_managed_node_groups : asg.autoscaling_group_arn]

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


# Only for DEBUG
output "cert_manager" {
    value = module.eks_blueprints_addons.cert_manager
}

output "cluster_autoscaler" {
    value = module.eks_blueprints_addons.cluster_autoscaler
}

output "aws_cloudwatch_metrics" {
    value = module.eks_blueprints_addons.aws_cloudwatch_metrics
}