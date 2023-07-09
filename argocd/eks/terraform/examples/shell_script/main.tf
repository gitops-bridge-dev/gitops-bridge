provider "aws" {
  region = local.region
}

locals {
  name   = var.name
  region = "us-west-2"
  environment = "control-plane"

  cluster_config = {
    cluster_name = module.eks.cluster_name,
    region       = local.region
    environment = local.environment


    aws_enable_cert_manager = module.eks_blueprints_addons.options.enable_cert_manager
    aws_cert_manager_iam_role_arn    = module.eks_blueprints_addons.cert_manager.iam_role_arn
    aws_cert_manager_namespace       = module.eks_blueprints_addons.cert_manager.namespace
    aws_cert_manager_service_account = module.eks_blueprints_addons.cert_manager.service_account

    aws_enable_cluster_autoscaler = module.eks_blueprints_addons.options.enable_cluster_autoscaler
    aws_cluster_autoscaler_iam_role_arn    = module.eks_blueprints_addons.cluster_autoscaler.iam_role_arn
    aws_cluster_autoscaler_namespace       = module.eks_blueprints_addons.cluster_autoscaler.namespace
    aws_cluster_autoscaler_service_account = module.eks_blueprints_addons.cluster_autoscaler.service_account
    aws_cluster_autoscaler_image_tag       = module.eks_blueprints_addons.cluster_autoscaler.image_tag

    aws_enable_aws_cloudwatch_metrics = module.eks_blueprints_addons.options.enable_aws_cloudwatch_metrics
    aws_cloudwatch_metrics_iam_role_arn    = module.eks_blueprints_addons.aws_cloudwatch_metrics.iam_role_arn
    aws_cloudwatch_metrics_namespace               = module.eks_blueprints_addons.aws_cloudwatch_metrics.namespace
    aws_cloudwatch_metrics_service_account = module.eks_blueprints_addons.aws_cloudwatch_metrics.service_account

    aws_enable_aws_efs_csi_driver = module.eks_blueprints_addons.options.enable_aws_efs_csi_driver
    aws_efs_csi_driver_iam_role_arn                = module.eks_blueprints_addons.aws_efs_csi_driver.iam_role_arn
    aws_efs_csi_driver_namespace                   = module.eks_blueprints_addons.aws_efs_csi_driver.namespace
    aws_efs_csi_driver_controller_service_account  = module.eks_blueprints_addons.aws_efs_csi_driver.controller_service_account
    aws_efs_csi_driver_node_service_account        = module.eks_blueprints_addons.aws_efs_csi_driver.node_service_account

    aws_enable_aws_fsx_csi_driver = module.eks_blueprints_addons.options.enable_aws_fsx_csi_driver
    aws_fsx_csi_driver_iam_role_arn                = module.eks_blueprints_addons.aws_fsx_csi_driver.iam_role_arn
    aws_fsx_csi_driver_namespace                   = module.eks_blueprints_addons.aws_fsx_csi_driver.namespace
    aws_fsx_csi_driver_controller_service_account  = module.eks_blueprints_addons.aws_fsx_csi_driver.controller_service_account
    aws_fsx_csi_driver_node_service_account        = module.eks_blueprints_addons.aws_fsx_csi_driver.node_service_account

    aws_enable_aws_privateca_issuer = module.eks_blueprints_addons.options.enable_aws_privateca_issuer
    aws_privateca_issuer_iam_role_arn     = module.eks_blueprints_addons.aws_privateca_issuer.iam_role_arn
    aws_privateca_issuer_namespace        = module.eks_blueprints_addons.aws_privateca_issuer.namespace
    aws_privateca_issuer_service_account  = module.eks_blueprints_addons.aws_privateca_issuer.service_account

    aws_enable_external_dns = module.eks_blueprints_addons.options.enable_external_dns
    aws_external_dns_iam_role_arn     = module.eks_blueprints_addons.external_dns.iam_role_arn
    aws_external_dns_namespace        = module.eks_blueprints_addons.external_dns.namespace
    aws_external_dns_service_account  = module.eks_blueprints_addons.external_dns.service_account

    aws_enable_external_secrets = module.eks_blueprints_addons.options.enable_external_secrets
    aws_external_secrets_iam_role_arn     = module.eks_blueprints_addons.external_secrets.iam_role_arn
    aws_external_secrets_namespace        = module.eks_blueprints_addons.external_secrets.namespace
    aws_external_secrets_service_account  = module.eks_blueprints_addons.external_secrets.service_account

    aws_enable_aws_load_balancer_controller = module.eks_blueprints_addons.options.enable_aws_load_balancer_controller
    aws_load_balancer_controller_iam_role_arn     = module.eks_blueprints_addons.aws_load_balancer_controller.iam_role_arn
    aws_load_balancer_controller_namespace        = module.eks_blueprints_addons.aws_load_balancer_controller.namespace
    aws_load_balancer_controller_service_account  = module.eks_blueprints_addons.aws_load_balancer_controller.service_account

    aws_enable_aws_for_fluentbit = module.eks_blueprints_addons.options.enable_aws_for_fluentbit
    aws_for_fluentbit_iam_role_arn     = module.eks_blueprints_addons.aws_for_fluentbit.iam_role_arn
    aws_for_fluentbit_namespace        = module.eks_blueprints_addons.aws_for_fluentbit.namespace
    aws_for_fluentbit_service_account  = module.eks_blueprints_addons.aws_for_fluentbit.service_account
    aws_for_fluentbit_log_group_name  = module.eks_blueprints_addons.aws_for_fluentbit.log_group_name

    aws_enable_aws_node_termination_handler = module.eks_blueprints_addons.options.enable_aws_node_termination_handler
    aws_node_termination_handler_iam_role_arn     = module.eks_blueprints_addons.aws_node_termination_handler.iam_role_arn
    aws_node_termination_handler_namespace        = module.eks_blueprints_addons.aws_node_termination_handler.namespace
    aws_node_termination_handler_service_account  = module.eks_blueprints_addons.aws_node_termination_handler.service_account
    aws_node_termination_handler_sqs_queue_url    = module.eks_blueprints_addons.aws_node_termination_handler.sqs_queue_url

    aws_enable_karpenter = module.eks_blueprints_addons.options.enable_karpenter
    aws_karpenter_iam_role_arn     = module.eks_blueprints_addons.karpenter.iam_role_arn
    aws_karpenter_namespace        = module.eks_blueprints_addons.karpenter.namespace
    aws_karpenter_service_account  = module.eks_blueprints_addons.karpenter.service_account
    aws_karpenter_sqs_queue_name    = module.eks_blueprints_addons.karpenter.sqs_queue_name
    aws_karpenter_cluster_endpoint = module.eks_blueprints_addons.karpenter.cluster_endpoint
    aws_karpenter_node_instance_profile_name = module.eks_blueprints_addons.karpenter.node_instance_profile_name

    aws_enable_velero = module.eks_blueprints_addons.options.enable_velero
    aws_velero_iam_role_arn            = module.eks_blueprints_addons.velero.iam_role_arn
    aws_velero_namespace               = module.eks_blueprints_addons.velero.namespace
    aws_velero_service_account         = module.eks_blueprints_addons.velero.service_account
    aws_velero_backup_s3_bucket_prefix = module.eks_blueprints_addons.velero.backup_s3_bucket_prefix
    aws_velero_backup_s3_bucket_name   = module.eks_blueprints_addons.velero.backup_s3_bucket_name

    enable_argocd = module.eks_blueprints_addons.options.enable_argocd
    enable_argo_rollouts = module.eks_blueprints_addons.options.enable_argo_rollouts
    enable_argo_workflows = module.eks_blueprints_addons.options.enable_argo_workflows
    enable_secrets_store_csi_driver = module.eks_blueprints_addons.options.enable_secrets_store_csi_driver
    enable_secrets_store_csi_driver_provider_aws = module.eks_blueprints_addons.options.enable_secrets_store_csi_driver_provider_aws
    enable_kube_prometheus_stack = module.eks_blueprints_addons.options.enable_kube_prometheus_stack
    enable_gatekeeper = module.eks_blueprints_addons.options.enable_gatekeeper
    enable_ingress_nginx = module.eks_blueprints_addons.options.enable_ingress_nginx
    enable_metrics_server = module.eks_blueprints_addons.options.enable_metrics_server
    enable_vpa = module.eks_blueprints_addons.options.enable_vpa
    enable_fargate_fluentbit = module.eks_blueprints_addons.options.enable_fargate_fluentbit
    enable_kyverno = module.eks_blueprints_addons.options.enable_kyverno
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
