output "aws_cloudwatch_metrics" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_cloudwatch_metrics,
    {
      namespace = local.aws_cloudwatch_metrics_namespace
      service_account = local.aws_cloudwatch_metrics_service_account
    }
  )
}

output "cert_manager" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.cert_manager,
    {
      namespace = local.cert_manager_namespace
      service_account = local.cert_manager_service_account
    }
  )
}

output "cluster_autoscaler" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.cluster_autoscaler,
    {
      namespace = local.cluster_autoscaler_namespace
      service_account = local.cluster_autoscaler_service_account
      image_tag = local.cluster_autoscaler_image_tag_selected
    }
  )
}

output "aws_efs_csi_driver" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_efs_csi_driver,
    {
      namespace = local.aws_efs_csi_driver_namespace
      controller_service_account = local.aws_efs_csi_driver_controller_service_account
      node_service_account = local.aws_efs_csi_driver_node_service_account
    }
  )
}

output "aws_fsx_csi_driver" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_fsx_csi_driver,
    {
      namespace = local.aws_fsx_csi_driver_namespace
      controller_service_account = local.aws_fsx_csi_driver_controller_service_account
      node_service_account = local.aws_fsx_csi_driver_node_service_account
    }
  )
}

output "aws_privateca_issuer" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_privateca_issuer,
    {
      namespace = local.aws_privateca_issuer_namespace
      service_account = local.aws_privateca_issuer_service_account
    }
  )
}

output "external_dns" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.external_dns,
    {
      namespace = local.external_dns_namespace
      service_account = local.external_dns_service_account
    }
  )
}

output "external_secrets" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.external_secrets,
    {
      namespace = local.external_secrets_namespace
      service_account = local.external_secrets_service_account
    }
  )
}

output "aws_load_balancer_controller" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_load_balancer_controller,
    {
      namespace = local.aws_load_balancer_controller_namespace
      service_account = local.aws_load_balancer_controller_service_account
    }
  )
}

output "aws_for_fluentbit" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.aws_for_fluentbit,
    {
      namespace = local.aws_for_fluentbit_namespace
      service_account = local.aws_for_fluentbit_service_account
      log_group_name = aws_cloudwatch_log_group.aws_for_fluentbit[0].name
    }
  )
}

output "aws_node_termination_handler" {
  description = "Map of attributes of the SQS and IRSA created"
  value = merge(
    module.aws_node_termination_handler,
    {
      sqs = module.aws_node_termination_handler_sqs
      namespace = local.aws_node_termination_handler_namespace
      service_account = local.aws_node_termination_handler_service_account
      sqs_queue_url = module.aws_node_termination_handler_sqs.queue_url
    }
  )
}

output "karpenter" {
  description = "Map of attributes of IRSA created"
  value = merge(
    module.karpenter,
    {
      node_instance_profile_name = local.karpenter_node_instance_profile_name
      node_iam_role_arn          = local.karpenter_node_iam_role_arn
      sqs                        = module.karpenter_sqs
      namespace                  = local.karpenter_namespace
      service_account            = local.karpenter_service_account_name
      sqs_queue_name             = module.karpenter_sqs.queue_name
      cluster_endpoint           = local.cluster_endpoint
    }
  )
}

output "velero" {
  description = "Map of attributes of the IRSA created"
  value = merge(
    module.velero,
    {
      namespace               = local.velero_namespace
      service_account         = local.velero_service_account
      backup_s3_bucket_prefix = local.velero_backup_s3_bucket_prefix
      backup_s3_bucket_name   = local.velero_backup_s3_bucket_name
    }
  )
}

#passthru variables to keep interface the same
output "options" {
  value = {
    enable_aws_efs_csi_driver = var.enable_aws_efs_csi_driver
    enable_aws_fsx_csi_driver = var.enable_aws_fsx_csi_driver
    enable_aws_cloudwatch_metrics = var.enable_aws_cloudwatch_metrics
    enable_aws_privateca_issuer = var.enable_aws_privateca_issuer
    enable_cert_manager = var.enable_cert_manager
    enable_cluster_autoscaler = var.enable_cluster_autoscaler
    enable_external_dns = var.enable_external_dns
    enable_external_secrets  = var.enable_external_secrets
    enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
    enable_aws_for_fluentbit = var.enable_aws_for_fluentbit
    enable_aws_node_termination_handler  = var.enable_aws_node_termination_handler
    enable_karpenter = var.enable_karpenter
    enable_velero = var.enable_velero

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
    enable_kyverno = var.enable_kyverno
  }
}

