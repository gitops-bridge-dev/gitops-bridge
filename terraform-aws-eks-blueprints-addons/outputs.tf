output "argo_rollouts" {
  description = "Map of attributes of the Helm release created"
  value       = module.argo_rollouts
}

output "argo_workflows" {
  description = "Map of attributes of the Helm release created"
  value       = module.argo_workflows
}

output "argocd" {
  description = "Map of attributes of the Helm release created"
  value       = module.argocd
}

output "aws_cloudwatch_metrics" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_cloudwatch_metrics
}

output "aws_efs_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_efs_csi_driver
}

output "aws_for_fluentbit" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_for_fluentbit
}

output "aws_fsx_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_fsx_csi_driver
}

output "aws_load_balancer_controller" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_load_balancer_controller
}

output "aws_node_termination_handler" {
  description = "Map of attributes of the Helm release and IRSA created"
  value = merge(
    module.aws_node_termination_handler,
    {
      sqs = module.aws_node_termination_handler_sqs
    }
  )
}

output "aws_privateca_issuer" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_privateca_issuer
}

output "cert_manager" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.cert_manager
}

output "cluster_autoscaler" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.cluster_autoscaler
}

output "cluster_proportional_autoscaler" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.cluster_proportional_autoscaler
}

output "eks_addons" {
  description = "Map of attributes for each EKS addons enabled"
  value       = aws_eks_addon.this
}

output "external_dns" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.external_dns
}

output "external_secrets" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.external_secrets
}

output "fargate_fluentbit" {
  description = "Map of attributes of the configmap and IAM policy created"
  value = {
    configmap  = kubernetes_config_map_v1.aws_logging
    iam_policy = aws_iam_policy.fargate_fluentbit
  }
}

output "gatekeeper" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.gatekeeper
}

output "ingress_nginx" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.ingress_nginx
}

output "karpenter" {
  description = "Map of attributes of the Helm release and IRSA created"
  value = merge(
    module.karpenter,
    {
      node_instance_profile_name = try(aws_iam_instance_profile.karpenter[0].name, "")
      node_iam_role_arn          = try(aws_iam_role.karpenter[0].arn, "")
      sqs                        = module.karpenter_sqs
    }
  )
}

output "kube_prometheus_stack" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.kube_prometheus_stack
}

output "metrics_server" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.metrics_server
}

output "secrets_store_csi_driver" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.secrets_store_csi_driver
}

output "secrets_store_csi_driver_provider_aws" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.secrets_store_csi_driver_provider_aws
}

output "velero" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.velero
}

output "vpa" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.vpa
}

output "aws_gateway_api_controller" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = module.aws_gateway_api_controller
}

################################################################################
# (Generic) Helm Release
################################################################################

output "helm_releases" {
  description = "Map of attributes of the Helm release created"
  value       = helm_release.this
}

################################################################################
# GitOps Bridge
################################################################################

output "gitops_metadata" {
  description = "GitOps Bridge metadata"
  value = {

    metadata_aws_vpc_id     = var.vpc_id
    metadata_aws_region     = local.region
    metadata_aws_account_id = local.account_id

    aws_enable_cert_manager                   = var.enable_cert_manager ? true : null
    metadata_aws_cert_manager_iam_role_arn    = var.enable_cert_manager ? module.cert_manager.iam_role_arn : null
    metadata_aws_cert_manager_namespace       = var.enable_cert_manager ? local.cert_manager_namespace : null
    metadata_aws_cert_manager_service_account = var.enable_cert_manager ? local.cert_manager_service_account : null

    aws_enable_cluster_autoscaler                   = var.enable_cluster_autoscaler ? true : null
    metadata_aws_cluster_autoscaler_iam_role_arn    = var.enable_cluster_autoscaler ? module.cluster_autoscaler.iam_role_arn : null
    metadata_aws_cluster_autoscaler_namespace       = var.enable_cluster_autoscaler ? local.cluster_autoscaler_namespace : null
    metadata_aws_cluster_autoscaler_service_account = var.enable_cluster_autoscaler ? local.cluster_autoscaler_service_account : null
    metadata_aws_cluster_autoscaler_image_tag       = var.enable_cluster_autoscaler ? local.cluster_autoscaler_image_tag_selected : null

    aws_enable_aws_cloudwatch_metrics               = var.enable_aws_cloudwatch_metrics ? true : null
    metadata_aws_cloudwatch_metrics_iam_role_arn    = var.enable_aws_cloudwatch_metrics ? module.aws_cloudwatch_metrics.iam_role_arn : null
    metadata_aws_cloudwatch_metrics_namespace       = var.enable_aws_cloudwatch_metrics ? local.aws_cloudwatch_metrics_namespace : null
    metadata_aws_cloudwatch_metrics_service_account = var.enable_aws_cloudwatch_metrics ? local.aws_cloudwatch_metrics_service_account : null

    aws_enable_aws_efs_csi_driver                          = var.enable_aws_efs_csi_driver ? true : null
    metadata_aws_efs_csi_driver_iam_role_arn               = var.enable_aws_efs_csi_driver ? module.aws_efs_csi_driver.iam_role_arn : null
    metadata_aws_efs_csi_driver_namespace                  = var.enable_aws_efs_csi_driver ? local.aws_efs_csi_driver_namespace : null
    metadata_aws_efs_csi_driver_controller_service_account = var.enable_aws_efs_csi_driver ? local.aws_efs_csi_driver_controller_service_account : null
    metadata_aws_efs_csi_driver_node_service_account       = var.enable_aws_efs_csi_driver ? local.aws_efs_csi_driver_node_service_account : null

    aws_enable_aws_fsx_csi_driver                          = var.enable_aws_fsx_csi_driver ? true : null
    metadata_aws_fsx_csi_driver_iam_role_arn               = var.enable_aws_fsx_csi_driver ? module.aws_fsx_csi_driver.iam_role_arn : null
    metadata_aws_fsx_csi_driver_namespace                  = var.enable_aws_fsx_csi_driver ? local.aws_fsx_csi_driver_namespace : null
    metadata_aws_fsx_csi_driver_controller_service_account = var.enable_aws_fsx_csi_driver ? local.aws_fsx_csi_driver_controller_service_account : null
    metadata_aws_fsx_csi_driver_node_service_account       = var.enable_aws_fsx_csi_driver ? local.aws_fsx_csi_driver_node_service_account : null

    aws_enable_aws_privateca_issuer               = var.enable_aws_privateca_issuer ? true : null
    metadata_aws_privateca_issuer_iam_role_arn    = var.enable_aws_privateca_issuer ? module.aws_privateca_issuer.iam_role_arn : null
    metadata_aws_privateca_issuer_namespace       = var.enable_aws_privateca_issuer ? local.aws_privateca_issuer_namespace : null
    metadata_aws_privateca_issuer_service_account = var.enable_aws_privateca_issuer ? local.aws_privateca_issuer_service_account : null

    aws_enable_external_dns                   = var.enable_external_dns ? true : null
    metadata_aws_external_dns_iam_role_arn    = var.enable_external_dns ? module.external_dns.iam_role_arn : null
    metadata_aws_external_dns_namespace       = var.enable_external_dns ? local.external_dns_namespace : null
    metadata_aws_external_dns_service_account = var.enable_external_dns ? local.external_dns_service_account : null

    aws_enable_external_secrets                   = var.enable_external_secrets ? true : null
    metadata_aws_external_secrets_iam_role_arn    = var.enable_external_dns ? module.external_secrets.iam_role_arn : null
    metadata_aws_external_secrets_namespace       = var.enable_external_dns ? local.external_secrets_namespace : null
    metadata_aws_external_secrets_service_account = var.enable_external_dns ? local.external_secrets_service_account : null

    aws_enable_aws_load_balancer_controller               = var.enable_aws_load_balancer_controller ? true : null
    metadata_aws_load_balancer_controller_iam_role_arn    = var.enable_aws_load_balancer_controller ? module.aws_load_balancer_controller.iam_role_arn : null
    metadata_aws_load_balancer_controller_namespace       = var.enable_aws_load_balancer_controller ? local.aws_load_balancer_controller_namespace : null
    metadata_aws_load_balancer_controller_service_account = var.enable_aws_load_balancer_controller ? local.aws_load_balancer_controller_service_account : null

    aws_enable_aws_for_fluentbit               = var.enable_aws_for_fluentbit ? true : null
    metadata_aws_for_fluentbit_iam_role_arn    = var.enable_aws_for_fluentbit ? module.aws_for_fluentbit.iam_role_arn : null
    metadata_aws_for_fluentbit_namespace       = var.enable_aws_for_fluentbit ? local.aws_for_fluentbit_namespace : null
    metadata_aws_for_fluentbit_service_account = var.enable_aws_for_fluentbit ? local.aws_for_fluentbit_service_account : null
    metadata_aws_for_fluentbit_log_group_name  = var.enable_aws_for_fluentbit && try(var.aws_for_fluentbit_cw_log_group.create, true) ? aws_cloudwatch_log_group.aws_for_fluentbit[0].name : null

    aws_enable_aws_node_termination_handler               = var.enable_aws_node_termination_handler ? true : null
    metadata_aws_node_termination_handler_iam_role_arn    = var.enable_aws_node_termination_handler ? module.aws_node_termination_handler.iam_role_arn : null
    metadata_aws_node_termination_handler_namespace       = var.enable_aws_node_termination_handler ? local.aws_node_termination_handler_namespace : null
    metadata_aws_node_termination_handler_service_account = var.enable_aws_node_termination_handler ? local.aws_node_termination_handler_service_account : null
    metadata_aws_node_termination_handler_sqs_queue_url   = var.enable_aws_node_termination_handler ? module.aws_node_termination_handler_sqs.queue_url : null

    aws_enable_karpenter                              = var.enable_karpenter ? true : null
    metadata_aws_karpenter_iam_role_arn               = var.enable_karpenter ? module.karpenter.iam_role_arn : null
    metadata_aws_karpenter_namespace                  = var.enable_karpenter ? local.karpenter_namespace : null
    metadata_aws_karpenter_service_account            = var.enable_karpenter ? local.karpenter_service_account_name : null
    metadata_aws_karpenter_sqs_queue_name             = var.enable_karpenter ? module.karpenter_sqs.queue_name : null
    metadata_aws_karpenter_cluster_endpoint           = var.enable_karpenter ? local.cluster_endpoint : null
    metadata_aws_karpenter_node_instance_profile_name = var.enable_karpenter ? local.karpenter_node_instance_profile_name : null

    aws_enable_velero                           = var.enable_velero ? true : null
    metadata_aws_velero_iam_role_arn            = var.enable_velero ? module.velero.iam_role_arn : null
    metadata_aws_velero_namespace               = var.enable_velero ? local.velero_namespace : null
    metadata_aws_velero_service_account         = var.enable_velero ? local.velero_service_account : null
    metadata_aws_velero_backup_s3_bucket_prefix = var.enable_velero ? local.velero_backup_s3_bucket_prefix : null
    metadata_aws_velero_backup_s3_bucket_name   = var.enable_velero ? local.velero_backup_s3_bucket_name : null

    aws_enable_aws_gateway_api_controller               = var.enable_aws_gateway_api_controller ? true : null
    metadata_aws_gateway_api_controller_iam_role_arn    = var.enable_aws_gateway_api_controller ? module.aws_gateway_api_controller.iam_role_arn : null
    metadata_aws_gateway_api_controller_namespace       = var.enable_aws_gateway_api_controller ? local.aws_gateway_api_controller_namespace : null
    metadata_aws_gateway_api_controller_service_account = var.enable_aws_gateway_api_controller ? local.aws_gateway_api_controller_service_account : null
    metadata_aws_gateway_api_controller_vpc_id          = var.enable_aws_gateway_api_controller ? var.vpc_id : null

    aws_enable_fargate_fluentbit                     = var.enable_fargate_fluentbit ? true : null
    metadata_aws_fargate_fluentbit_log_group_name    = var.enable_fargate_fluentbit && try(var.fargate_fluentbit_cw_log_group.create, true) ? try(var.fargate_fluentbit.cwlog_group, aws_cloudwatch_log_group.fargate_fluentbit[0].name) : null
    metadata_aws_fargate_fluentbit_log_stream_prefix = var.enable_fargate_fluentbit ? local.fargate_fluentbit_cwlog_stream_prefix : null
  }
}
