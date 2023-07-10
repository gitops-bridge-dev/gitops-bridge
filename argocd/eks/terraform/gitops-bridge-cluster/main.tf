data "aws_region" "current" {}

locals {

  cluster_config = merge ({
    cluster_name = var.cluster_name,
    region       = data.aws_region.current.name
    environment  = var.environment
  },{
    aws_account_id = try(var.metadata.account_id,null)
    aws_cert_manager_iam_role_arn    = try(var.metadata.cert_manager.iam_role_arn,null)
    aws_cert_manager_namespace       = try(var.metadata.cert_manager.namespace,null)
    aws_cert_manager_service_account = try(var.metadata.cert_manager.service_account,null)

    aws_cluster_autoscaler_iam_role_arn    = try(var.metadata.cluster_autoscaler.iam_role_arn,null)
    aws_cluster_autoscaler_namespace       = try(var.metadata.cluster_autoscaler.namespace,null)
    aws_cluster_autoscaler_service_account = try(var.metadata.cluster_autoscaler.service_account,null)
    aws_cluster_autoscaler_image_tag       = try(var.metadata.cluster_autoscaler.image_tag,null)

    aws_cloudwatch_metrics_iam_role_arn    = try(var.metadata.aws_cloudwatch_metrics.iam_role_arn,null)
    aws_cloudwatch_metrics_namespace               = try(var.metadata.aws_cloudwatch_metrics.namespace,null)
    aws_cloudwatch_metrics_service_account = try(var.metadata.aws_cloudwatch_metrics.service_account,null)

    aws_efs_csi_driver_iam_role_arn                = try(var.metadata.aws_efs_csi_driver.iam_role_arn,null)
    aws_efs_csi_driver_namespace                   = try(var.metadata.aws_efs_csi_driver.namespace,null)
    aws_efs_csi_driver_controller_service_account  = try(var.metadata.aws_efs_csi_driver.controller_service_account,null)
    aws_efs_csi_driver_node_service_account        = try(var.metadata.aws_efs_csi_driver.node_service_account,null)


    aws_fsx_csi_driver_iam_role_arn                = try(var.metadata.aws_fsx_csi_driver.iam_role_arn,null)
    aws_fsx_csi_driver_namespace                   = try(var.metadata.aws_fsx_csi_driver.namespace,null)
    aws_fsx_csi_driver_controller_service_account  = try(var.metadata.aws_fsx_csi_driver.controller_service_account,null)
    aws_fsx_csi_driver_node_service_account        = try(var.metadata.aws_fsx_csi_driver.node_service_account,null)


    aws_privateca_issuer_iam_role_arn     = try(var.metadata.aws_privateca_issuer.iam_role_arn,null)
    aws_privateca_issuer_namespace        = try(var.metadata.aws_privateca_issuer.namespace,null)
    aws_privateca_issuer_service_account  = try(var.metadata.aws_privateca_issuer.service_account,null)


    aws_external_dns_iam_role_arn     = try(var.metadata.external_dns.iam_role_arn,null)
    aws_external_dns_namespace        = try(var.metadata.external_dns.namespace,null)
    aws_external_dns_service_account  = try(var.metadata.external_dns.service_account,null)


    aws_external_secrets_iam_role_arn     = try(var.metadata.external_secrets.iam_role_arn,null)
    aws_external_secrets_namespace        = try(var.metadata.external_secrets.namespace,null)
    aws_external_secrets_service_account  = try(var.metadata.external_secrets.service_account,null)

    aws_load_balancer_controller_iam_role_arn     = try(var.metadata.aws_load_balancer_controller.iam_role_arn,null)
    aws_load_balancer_controller_namespace        = try(var.metadata.aws_load_balancer_controller.namespace,null)
    aws_load_balancer_controller_service_account  = try(var.metadata.aws_load_balancer_controller.service_account,null)

    aws_for_fluentbit_iam_role_arn     = try(var.metadata.aws_for_fluentbit.iam_role_arn,null)
    aws_for_fluentbit_namespace        = try(var.metadata.aws_for_fluentbit.namespace,null)
    aws_for_fluentbit_service_account  = try(var.metadata.aws_for_fluentbit.service_account,null)
    aws_for_fluentbit_log_group_name  = try(var.metadata.aws_for_fluentbit.log_group_name,null)

    aws_node_termination_handler_iam_role_arn     = try(var.metadata.aws_node_termination_handler.iam_role_arn,null)
    aws_node_termination_handler_namespace        = try(var.metadata.aws_node_termination_handler.namespace,null)
    aws_node_termination_handler_service_account  = try(var.metadata.aws_node_termination_handler.service_account,null)
    aws_node_termination_handler_sqs_queue_url    = try(var.metadata.aws_node_termination_handler.sqs_queue_url,null)

    aws_karpenter_iam_role_arn     = try(var.metadata.karpenter.iam_role_arn,null)
    aws_karpenter_namespace        = try(var.metadata.karpenter.namespace,null)
    aws_karpenter_service_account  = try(var.metadata.karpenter.service_account,null)
    aws_karpenter_sqs_queue_name    = try(var.metadata.karpenter.sqs_queue_name,null)
    aws_karpenter_cluster_endpoint = try(var.metadata.karpenter.cluster_endpoint,null)
    aws_karpenter_node_instance_profile_name = try(var.metadata.karpenter.node_instance_profile_name,null)

    aws_velero_iam_role_arn            = try(var.metadata.velero.iam_role_arn,null)
    aws_velero_namespace               = try(var.metadata.velero.namespace,null)
    aws_velero_service_account         = try(var.metadata.velero.service_account,null)
    aws_velero_backup_s3_bucket_prefix = try(var.metadata.velero.backup_s3_bucket_prefix,null)
    aws_velero_backup_s3_bucket_name   = try(var.metadata.velero.backup_s3_bucket_name,null)

    aws_gateway_api_controller_iam_role_arn            = try(var.metadata.aws_gateway_api_controller.iam_role_arn,null)
    aws_gateway_api_controller_namespace               = try(var.metadata.aws_gateway_api_controller.namespace,null)
    aws_gateway_api_controller_service_account         = try(var.metadata.aws_gateway_api_controller.service_account,null)
    aws_gateway_api_controller_vpc_id = try(var.metadata.aws_gateway_api_controller.vpc_id,null)


  },
  {
    for k, v in try(var.metadata.addons,{}) :
    k => v
    if startswith(k, "aws_enable_")
  },
  { for k, v in var.addons : k => v }
  )
}

resource "shell_script" "gitops_bridge" {

  lifecycle_commands {
    create = file("${path.module}/templates/create.sh")
    update = file("${path.module}/templates/create.sh")
    read = file("${path.module}/templates/read.sh")
    delete = file("${path.module}/templates/delete.sh")
  }

  environment = local.cluster_config

}
