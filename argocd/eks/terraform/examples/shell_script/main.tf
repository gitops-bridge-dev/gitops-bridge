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
    cert_manager_namespace    = "cert-manager"

    cluster_autoscaler_iam_role_arn = module.eks_blueprints_addons.cluster_autoscaler.iam_role_arn
    cluster_autoscaler_sa           = "cluster-autoscaler-sa"
    cluster_autoscaler_image_tag    = try(local.cluster_autoscaler_image_tag[module.eks.cluster_version], "v${module.eks.cluster_version}.0")
    cluster_autoscaler_namespace    = "kube-system"

    aws_cloudwatch_metrics_iam_role_arn = module.eks_blueprints_addons.aws_cloudwatch_metrics.iam_role_arn
    aws_cloudwatch_metrics_sa           = "aws-cloudwatch-metrics"
    aws_cloudwatch_namespace            = "amazon-cloudwatch"

    enable_argocd = local.enable_argocd
  }
}


resource "shell_script" "day2ops" {

  lifecycle_commands {
    create = templatefile(
    "${path.module}/templates/create.tftpl", local.cluster_config)
    update = templatefile(
    "${path.module}/templates/create.tftpl", local.cluster_config)
    read = templatefile(
    "${path.module}/templates/create.tftpl", local.cluster_config)
    delete = templatefile(
    "${path.module}/templates/delete.tftpl", local.cluster_config)
  }

  depends_on = [
    module.eks
  ]
}


# "user" can be accessed like a normal Terraform map
output "user" {
  value = shell_script.day2ops.output["London"]
}
