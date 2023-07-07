output "aws_cloudwatch_metrics" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = {
    namespace = local.aws_cloudwatch_metrics_namespace
    iam_role_arn = module.aws_cloudwatch_metrics.iam_role_arn
    service_account = local.aws_cloudwatch_metrics_service_account
  }
}


output "cert_manager" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = {
    namespace = local.cert_manager_namespace
    iam_role_arn = module.cert_manager.iam_role_arn
    service_account = local.cert_manager_service_account
  }
}

output "cluster_autoscaler" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = {
    namespace = local.cluster_autoscaler_namespace
    iam_role_arn = module.cluster_autoscaler.iam_role_arn
    service_account = local.cluster_autoscaler_service_account
    image_tag = local.cluster_autoscaler_image_tag_selected
  }
}

output "aws_efs_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = {
    namespace = local.aws_efs_csi_driver_namespace
    iam_role_arn = module.aws_efs_csi_driver.iam_role_arn
    controller_service_account = local.aws_efs_csi_driver_controller_service_account
    node_service_account = local.aws_efs_csi_driver_node_service_account
  }
}