data "aws_region" "current" {}

locals {

  cluster_config = merge ({
    cluster_name = var.cluster_name,
    region       = data.aws_region.current.name
    environment  = var.environment
  },{
    aws_enable_cert_manager = var.eks_blueprints_addons.options.enable_cert_manager
    aws_cert_manager_iam_role_arn    = var.eks_blueprints_addons.cert_manager.iam_role_arn
    aws_cert_manager_namespace       = var.eks_blueprints_addons.cert_manager.namespace
    aws_cert_manager_service_account = var.eks_blueprints_addons.cert_manager.service_account

    aws_enable_cluster_autoscaler = var.eks_blueprints_addons.options.enable_cluster_autoscaler
    aws_cluster_autoscaler_iam_role_arn    = var.eks_blueprints_addons.cluster_autoscaler.iam_role_arn
    aws_cluster_autoscaler_namespace       = var.eks_blueprints_addons.cluster_autoscaler.namespace
    aws_cluster_autoscaler_service_account = var.eks_blueprints_addons.cluster_autoscaler.service_account
    aws_cluster_autoscaler_image_tag       = var.eks_blueprints_addons.cluster_autoscaler.image_tag

    aws_enable_aws_cloudwatch_metrics = var.eks_blueprints_addons.options.enable_aws_cloudwatch_metrics
    aws_cloudwatch_metrics_iam_role_arn    = var.eks_blueprints_addons.aws_cloudwatch_metrics.iam_role_arn
    aws_cloudwatch_metrics_namespace               = var.eks_blueprints_addons.aws_cloudwatch_metrics.namespace
    aws_cloudwatch_metrics_service_account = var.eks_blueprints_addons.aws_cloudwatch_metrics.service_account

    aws_enable_aws_efs_csi_driver = var.eks_blueprints_addons.options.enable_aws_efs_csi_driver
    aws_efs_csi_driver_iam_role_arn                = var.eks_blueprints_addons.aws_efs_csi_driver.iam_role_arn
    aws_efs_csi_driver_namespace                   = var.eks_blueprints_addons.aws_efs_csi_driver.namespace
    aws_efs_csi_driver_controller_service_account  = var.eks_blueprints_addons.aws_efs_csi_driver.controller_service_account
    aws_efs_csi_driver_node_service_account        = var.eks_blueprints_addons.aws_efs_csi_driver.node_service_account

    aws_enable_aws_fsx_csi_driver = var.eks_blueprints_addons.options.enable_aws_fsx_csi_driver
    aws_fsx_csi_driver_iam_role_arn                = var.eks_blueprints_addons.aws_fsx_csi_driver.iam_role_arn
    aws_fsx_csi_driver_namespace                   = var.eks_blueprints_addons.aws_fsx_csi_driver.namespace
    aws_fsx_csi_driver_controller_service_account  = var.eks_blueprints_addons.aws_fsx_csi_driver.controller_service_account
    aws_fsx_csi_driver_node_service_account        = var.eks_blueprints_addons.aws_fsx_csi_driver.node_service_account

    aws_enable_aws_privateca_issuer = var.eks_blueprints_addons.options.enable_aws_privateca_issuer
    aws_privateca_issuer_iam_role_arn     = var.eks_blueprints_addons.aws_privateca_issuer.iam_role_arn
    aws_privateca_issuer_namespace        = var.eks_blueprints_addons.aws_privateca_issuer.namespace
    aws_privateca_issuer_service_account  = var.eks_blueprints_addons.aws_privateca_issuer.service_account

    aws_enable_external_dns = var.eks_blueprints_addons.options.enable_external_dns
    aws_external_dns_iam_role_arn     = var.eks_blueprints_addons.external_dns.iam_role_arn
    aws_external_dns_namespace        = var.eks_blueprints_addons.external_dns.namespace
    aws_external_dns_service_account  = var.eks_blueprints_addons.external_dns.service_account

    aws_enable_external_secrets = var.eks_blueprints_addons.options.enable_external_secrets
    aws_external_secrets_iam_role_arn     = var.eks_blueprints_addons.external_secrets.iam_role_arn
    aws_external_secrets_namespace        = var.eks_blueprints_addons.external_secrets.namespace
    aws_external_secrets_service_account  = var.eks_blueprints_addons.external_secrets.service_account

    aws_enable_aws_load_balancer_controller = var.eks_blueprints_addons.options.enable_aws_load_balancer_controller
    aws_load_balancer_controller_iam_role_arn     = var.eks_blueprints_addons.aws_load_balancer_controller.iam_role_arn
    aws_load_balancer_controller_namespace        = var.eks_blueprints_addons.aws_load_balancer_controller.namespace
    aws_load_balancer_controller_service_account  = var.eks_blueprints_addons.aws_load_balancer_controller.service_account

    aws_enable_aws_for_fluentbit = var.eks_blueprints_addons.options.enable_aws_for_fluentbit
    aws_for_fluentbit_iam_role_arn     = var.eks_blueprints_addons.aws_for_fluentbit.iam_role_arn
    aws_for_fluentbit_namespace        = var.eks_blueprints_addons.aws_for_fluentbit.namespace
    aws_for_fluentbit_service_account  = var.eks_blueprints_addons.aws_for_fluentbit.service_account
    aws_for_fluentbit_log_group_name  = var.eks_blueprints_addons.aws_for_fluentbit.log_group_name

    aws_enable_aws_node_termination_handler = var.eks_blueprints_addons.options.enable_aws_node_termination_handler
    aws_node_termination_handler_iam_role_arn     = var.eks_blueprints_addons.aws_node_termination_handler.iam_role_arn
    aws_node_termination_handler_namespace        = var.eks_blueprints_addons.aws_node_termination_handler.namespace
    aws_node_termination_handler_service_account  = var.eks_blueprints_addons.aws_node_termination_handler.service_account
    aws_node_termination_handler_sqs_queue_url    = var.eks_blueprints_addons.aws_node_termination_handler.sqs_queue_url

    aws_enable_karpenter = var.eks_blueprints_addons.options.enable_karpenter
    aws_karpenter_iam_role_arn     = var.eks_blueprints_addons.karpenter.iam_role_arn
    aws_karpenter_namespace        = var.eks_blueprints_addons.karpenter.namespace
    aws_karpenter_service_account  = var.eks_blueprints_addons.karpenter.service_account
    aws_karpenter_sqs_queue_name    = var.eks_blueprints_addons.karpenter.sqs_queue_name
    aws_karpenter_cluster_endpoint = var.eks_blueprints_addons.karpenter.cluster_endpoint
    aws_karpenter_node_instance_profile_name = var.eks_blueprints_addons.karpenter.node_instance_profile_name

    aws_enable_velero = var.eks_blueprints_addons.options.enable_velero
    aws_velero_iam_role_arn            = var.eks_blueprints_addons.velero.iam_role_arn
    aws_velero_namespace               = var.eks_blueprints_addons.velero.namespace
    aws_velero_service_account         = var.eks_blueprints_addons.velero.service_account
    aws_velero_backup_s3_bucket_prefix = var.eks_blueprints_addons.velero.backup_s3_bucket_prefix
    aws_velero_backup_s3_bucket_name   = var.eks_blueprints_addons.velero.backup_s3_bucket_name
  },
  { for k, v in var.addons : k => v }
  )
}

resource "shell_script" "gitops_bridge" {

  lifecycle_commands {
    create = file("${path.module}/templates/create.sh")
    update = file("${path.module}/templates/create.sh")
    read = file("${path.module}/templates/create.sh")
    delete = file("${path.module}/templates/delete.sh")
  }

  environment = local.cluster_config

}
