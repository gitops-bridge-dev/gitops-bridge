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

    cert_manager_iam_role_arn = module.eks_blueprints_addons.cert_manager.iam_role_arn
    cert_manager_namespace    = module.eks_blueprints_addons.cert_manager.namespace

    cluster_autoscaler_iam_role_arn = module.eks_blueprints_addons.cluster_autoscaler.iam_role_arn
    cluster_autoscaler_sa           = module.eks_blueprints_addons.cluster_autoscaler.service_account
    cluster_autoscaler_image_tag    = module.eks_blueprints_addons.cluster_autoscaler.image_tag
    cluster_autoscaler_namespace    = module.eks_blueprints_addons.cluster_autoscaler.namespace

    aws_cloudwatch_metrics_iam_role_arn = module.eks_blueprints_addons.aws_cloudwatch_metrics.iam_role_arn
    aws_cloudwatch_metrics_sa           = module.eks_blueprints_addons.aws_cloudwatch_metrics.service_account
    aws_cloudwatch_namespace            = module.eks_blueprints_addons.aws_cloudwatch_metrics.namespace

    aws_efs_csi_driver_iam_role_arn                = module.eks_blueprints_addons.aws_efs_csi_driver.iam_role_arn
    aws_efs_csi_driver_controller_service_account  = module.eks_blueprints_addons.aws_efs_csi_driver.controller_service_account
    aws_efs_csi_driver_node_service_account        = module.eks_blueprints_addons.aws_efs_csi_driver.node_service_account
    aws_efs_csi_driver_namespace                   = module.eks_blueprints_addons.aws_efs_csi_driver.namespace

    aws_fsx_csi_driver_iam_role_arn                = module.eks_blueprints_addons.aws_fsx_csi_driver.iam_role_arn
    aws_fsx_csi_driver_controller_service_account  = module.eks_blueprints_addons.aws_fsx_csi_driver.controller_service_account
    aws_fsx_csi_driver_node_service_account        = module.eks_blueprints_addons.aws_fsx_csi_driver.node_service_account
    aws_fsx_csi_driver_namespace                   = module.eks_blueprints_addons.aws_fsx_csi_driver.namespace

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
