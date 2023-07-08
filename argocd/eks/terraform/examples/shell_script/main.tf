provider "aws" {
  region = local.region
}

locals {
  name   = var.name
  region = "us-west-2"

  enable_argocd = var.control_plane

  cluster_config = {
    cluster_name = module.eks.cluster_name,
    region       = local.region

    cert_manager_iam_role_arn    = module.eks_blueprints_addons.cert_manager.iam_role_arn
    cert_manager_namespace       = module.eks_blueprints_addons.cert_manager.namespace
    cert_manager_service_account = module.eks_blueprints_addons.cert_manager.service_account

    cluster_autoscaler_iam_role_arn    = module.eks_blueprints_addons.cluster_autoscaler.iam_role_arn
    cluster_autoscaler_namespace       = module.eks_blueprints_addons.cluster_autoscaler.namespace
    cluster_autoscaler_service_account = module.eks_blueprints_addons.cluster_autoscaler.service_account
    cluster_autoscaler_image_tag       = module.eks_blueprints_addons.cluster_autoscaler.image_tag

    aws_cloudwatch_metrics_iam_role_arn    = module.eks_blueprints_addons.aws_cloudwatch_metrics.iam_role_arn
    aws_cloudwatch_namespace               = module.eks_blueprints_addons.aws_cloudwatch_metrics.namespace
    aws_cloudwatch_metrics_service_account = module.eks_blueprints_addons.aws_cloudwatch_metrics.service_account

    aws_efs_csi_driver_iam_role_arn                = module.eks_blueprints_addons.aws_efs_csi_driver.iam_role_arn
    aws_efs_csi_driver_namespace                   = module.eks_blueprints_addons.aws_efs_csi_driver.namespace
    aws_efs_csi_driver_controller_service_account  = module.eks_blueprints_addons.aws_efs_csi_driver.controller_service_account
    aws_efs_csi_driver_node_service_account        = module.eks_blueprints_addons.aws_efs_csi_driver.node_service_account

    aws_fsx_csi_driver_iam_role_arn                = module.eks_blueprints_addons.aws_fsx_csi_driver.iam_role_arn
    aws_fsx_csi_driver_namespace                   = module.eks_blueprints_addons.aws_fsx_csi_driver.namespace
    aws_fsx_csi_driver_controller_service_account  = module.eks_blueprints_addons.aws_fsx_csi_driver.controller_service_account
    aws_fsx_csi_driver_node_service_account        = module.eks_blueprints_addons.aws_fsx_csi_driver.node_service_account

    aws_privateca_issuer_iam_role_arn     = module.eks_blueprints_addons.aws_privateca_issuer.iam_role_arn
    aws_privateca_issuer_namespace        = module.eks_blueprints_addons.aws_privateca_issuer.namespace
    aws_privateca_issuer_service_account  = module.eks_blueprints_addons.aws_privateca_issuer.service_account

    external_dns_iam_role_arn     = module.eks_blueprints_addons.external_dns.iam_role_arn
    external_dns_namespace        = module.eks_blueprints_addons.external_dns.namespace
    external_dns_service_account  = module.eks_blueprints_addons.external_dns.service_account

    external_secrets_iam_role_arn     = module.eks_blueprints_addons.external_secrets.iam_role_arn
    external_secrets_namespace        = module.eks_blueprints_addons.external_secrets.namespace
    external_secrets_service_account  = module.eks_blueprints_addons.external_secrets.service_account

    aws_load_balancer_controller_iam_role_arn     = module.eks_blueprints_addons.aws_load_balancer_controller.iam_role_arn
    aws_load_balancer_controller_namespace        = module.eks_blueprints_addons.aws_load_balancer_controller.namespace
    aws_load_balancer_controller_service_account  = module.eks_blueprints_addons.aws_load_balancer_controller.service_account

    aws_for_fluentbit_iam_role_arn     = module.eks_blueprints_addons.aws_for_fluentbit.iam_role_arn
    aws_for_fluentbit_namespace        = module.eks_blueprints_addons.aws_for_fluentbit.namespace
    aws_for_fluentbit_service_account  = module.eks_blueprints_addons.aws_for_fluentbit.service_account
    aws_for_fluentbit_log_group_name  = module.eks_blueprints_addons.aws_for_fluentbit.log_group_name

    aws_node_termination_handler_iam_role_arn     = module.eks_blueprints_addons.aws_node_termination_handler.iam_role_arn
    aws_node_termination_handler_namespace        = module.eks_blueprints_addons.aws_node_termination_handler.namespace
    aws_node_termination_handler_service_account  = module.eks_blueprints_addons.aws_node_termination_handler.service_account
    aws_node_termination_handler_sqs_queue_url    = module.eks_blueprints_addons.aws_node_termination_handler.sqs_queue_url

    aws_karpenter_iam_role_arn     = module.eks_blueprints_addons.karpenter.iam_role_arn
    aws_karpenter_namespace        = module.eks_blueprints_addons.karpenter.namespace
    aws_karpenter_service_account  = module.eks_blueprints_addons.karpenter.service_account
    aws_karpenter_sqs_queue_name    = module.eks_blueprints_addons.karpenter.sqs_queue_name
    aws_karpenter_cluster_endpoint = module.eks_blueprints_addons.karpenter.cluster_endpoint
    aws_karpenter_node_instance_profile_name = module.eks_blueprints_addons.karpenter.node_instance_profile_name

    aws_velero_iam_role_arn            = module.eks_blueprints_addons.velero.iam_role_arn
    aws_velero_namespace               = module.eks_blueprints_addons.velero.namespace
    aws_velero_service_account         = module.eks_blueprints_addons.velero.service_account
    aws_velero_backup_s3_bucket_prefix = module.eks_blueprints_addons.velero.backup_s3_bucket_prefix
    aws_velero_backup_s3_bucket_name   = module.eks_blueprints_addons.velero.backup_s3_bucket_name


    enable_argocd = local.enable_argocd
  }
}



resource "shell_script" "gitops_bridge" {

  lifecycle_commands {
    create = file("${path.module}/templates/create.sh")
    update = file("${path.module}/templates/create.sh")
    read = file("${path.module}/templates/create.sh")
    delete = file("${path.module}/templates/delete.sh")
  }

  environment = local.cluster_config

  depends_on = [
    module.eks
  ]
}
