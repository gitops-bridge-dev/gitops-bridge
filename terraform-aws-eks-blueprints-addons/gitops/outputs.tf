output "aws_cloudwatch_metrics" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_cloudwatch_metrics,
    {
      namespace = var.enable_aws_cloudwatch_metrics ? local.aws_cloudwatch_metrics_namespace: null
      service_account = var.enable_aws_cloudwatch_metrics ? local.aws_cloudwatch_metrics_service_account: null
    }
  )
}

output "cert_manager" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.cert_manager, var.enable_cert_manager ?
    {
      namespace = local.cert_manager_namespace
      service_account = local.cert_manager_service_account
    }: null
  )
}

output "cluster_autoscaler" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.cluster_autoscaler, var.enable_cluster_autoscaler ?
    {
      namespace =  local.cluster_autoscaler_namespace
      service_account = local.cluster_autoscaler_service_account
      image_tag = local.cluster_autoscaler_image_tag_selected
    }: null
  )
}

output "aws_efs_csi_driver" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_efs_csi_driver, var.enable_aws_efs_csi_driver ?
    {
      namespace = local.aws_efs_csi_driver_namespace
      controller_service_account = local.aws_efs_csi_driver_controller_service_account
      node_service_account = local.aws_efs_csi_driver_node_service_account
    }: null
  )
}

output "aws_fsx_csi_driver" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_fsx_csi_driver, var.enable_aws_fsx_csi_driver ?
    {
      namespace = local.aws_fsx_csi_driver_namespace
      controller_service_account = local.aws_fsx_csi_driver_controller_service_account
      node_service_account = local.aws_fsx_csi_driver_node_service_account
    }: null
  )
}

output "aws_privateca_issuer" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_privateca_issuer, var.enable_aws_privateca_issuer ?
    {
      namespace = local.aws_privateca_issuer_namespace
      service_account = local.aws_privateca_issuer_service_account
    }: null
  )
}

output "external_dns" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.external_dns, var.enable_external_dns ?
    {
      namespace = local.external_dns_namespace
      service_account = local.external_dns_service_account
    }: null
  )
}

output "external_secrets" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.external_secrets, var.enable_external_secrets ?
    {
      namespace = local.external_secrets_namespace
      service_account = local.external_secrets_service_account
    }: null
  )
}

output "aws_load_balancer_controller" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_load_balancer_controller, var.enable_aws_load_balancer_controller ?
    {
      namespace = local.aws_load_balancer_controller_namespace
      service_account = local.aws_load_balancer_controller_service_account
    }: null
  )
}

output "aws_for_fluentbit" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_for_fluentbit, var.enable_aws_for_fluentbit ?
    {
      namespace = local.aws_for_fluentbit_namespace
      service_account = local.aws_for_fluentbit_service_account
      log_group_name = try(aws_cloudwatch_log_group.aws_for_fluentbit[0].name, "")
    }: null
  )
}

output "aws_node_termination_handler" {
  description = "Map of attributes of the SQS and IRSA created"
  value = merge(
    module.aws_node_termination_handler, var.enable_aws_node_termination_handler ?
    {
      sqs = module.aws_node_termination_handler_sqs
      namespace = local.aws_node_termination_handler_namespace
      service_account = local.aws_node_termination_handler_service_account
      sqs_queue_url = module.aws_node_termination_handler_sqs.queue_url
    }: null
  )
}

output "karpenter" {
  description = "Map of attributes of IRSA created"
  value = merge(
    module.karpenter, var.enable_karpenter ?
    {
      node_instance_profile_name = local.karpenter_node_instance_profile_name
      node_iam_role_arn          = local.karpenter_node_iam_role_arn
      sqs                        = module.karpenter_sqs
      namespace                  = local.karpenter_namespace
      service_account            = local.karpenter_service_account_name
      sqs_queue_name             = module.karpenter_sqs.queue_name
      cluster_endpoint           = local.cluster_endpoint
    }: null
  )
}

output "velero" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.velero, var.enable_velero ?
    {
      namespace               = local.velero_namespace
      service_account         = local.velero_service_account
      backup_s3_bucket_prefix = local.velero_backup_s3_bucket_prefix
      backup_s3_bucket_name   = local.velero_backup_s3_bucket_name
    }: null
  )
}

output "aws_gateway_api_controller" {
  description = "Map of attributes of the IRSA created"
  value       = merge(
  module.aws_gateway_api_controller, var.enable_aws_gateway_api_controller ?
    {
      namespace               = local.aws_gateway_api_controller_namespace
      service_account         = local.aws_gateway_api_controller_service_account
    }: null
  )
}


output "fargate_fluentbit" {
  description = "Map of attributes of the configmap and IAM policy created"
  value = {
    iam_policy = aws_iam_policy.fargate_fluentbit
    log_group_name = try(var.fargate_fluentbit.cwlog_group, aws_cloudwatch_log_group.fargate_fluentbit[0].name,null)
    log_stream_prefix = local.fargate_fluentbit_cwlog_stream_prefix
  }
}

output "addons" {
  value = {
    aws_enable_aws_efs_csi_driver = var.enable_aws_efs_csi_driver ? true : null
    aws_enable_aws_fsx_csi_driver = var.enable_aws_fsx_csi_driver ? true : null
    aws_enable_aws_cloudwatch_metrics = var.enable_aws_cloudwatch_metrics ? true : null
    aws_enable_aws_privateca_issuer = var.enable_aws_privateca_issuer ? true : null
    aws_enable_cert_manager = var.enable_cert_manager ? true : null
    aws_enable_cluster_autoscaler = var.enable_cluster_autoscaler ? true : null
    aws_enable_external_dns = var.enable_external_dns ? true : null
    aws_enable_external_secrets  = var.enable_external_secrets ? true : null
    aws_enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller ? true : null
    aws_enable_aws_for_fluentbit = var.enable_aws_for_fluentbit ? true : null
    aws_enable_aws_node_termination_handler  = var.enable_aws_node_termination_handler ? true : null
    aws_enable_karpenter = var.enable_karpenter ? true : null
    aws_enable_velero = var.enable_velero ? true : null
    aws_enable_aws_gateway_api_controller = var.enable_aws_gateway_api_controller ? true : null
    aws_enable_fargate_fluentbit = var.enable_fargate_fluentbit ? true : null

    #passthru variables to keep interface the same
    # TBD not sure to remove this variables
    enable_argocd = var.enable_argocd
    enable_argo_rollouts = var.enable_argo_rollouts
    enable_argo_workflows = var.enable_argo_workflows
    enable_secrets_store_csi_driver = var.enable_secrets_store_csi_driver
    enable_secrets_store_csi_driver_provider_aws = var.enable_secrets_store_csi_driver_provider_aws
    enable_kube_prometheus_stack = var.enable_kube_prometheus_stack
    enable_gatekeeper = var.enable_gatekeeper
    enable_ingress_nginx = var.enable_ingress_nginx
    enable_metrics_server = var.enable_metrics_server
    enable_vpa = var.enable_vpa
    enable_fargate_fluentbit = var.enable_fargate_fluentbit
  }
}

output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region
}

output "vpc_id" {
  value = var.vpc_id
}
