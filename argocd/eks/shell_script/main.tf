provider "aws" {
  region = local.region
}

locals {
  name   = "ex-${replace(basename(path.cwd), "_", "-")}"
  region = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/csantanapr/terraform-gitops-bridge"
  }
  # Lookup map to pull latest cluster-autoscaler patch version given the cluster version
  cluster_autoscaler_image_tag = {
    "1.20" = "v1.20.3"
    "1.21" = "v1.21.3"
    "1.22" = "v1.22.3"
    "1.23" = "v1.23.1"
    "1.24" = "v1.24.1"
    "1.25" = "v1.25.1"
    "1.26" = "v1.26.2"
    "1.27" = "v1.27.2"
  }
  enable_argocd = true
}


resource "shell_script" "day2ops" {

  lifecycle_commands {
    create = templatefile(
      "${path.module}/templates/create.tftpl",
      {
        cluster_name        = module.eks.cluster_name,
        region              = local.region
        cert_manager_iam_role_arn = module.eks_blueprints_addons.cert_manager.iam_role_arn
        cluster_autoscaler_iam_role_arn = module.eks_blueprints_addons.cluster_autoscaler.iam_role_arn
        cluster_autoscaler_sa = "cluster-autoscaler-sa"
        cluster_autoscaler_image_tag = try(local.cluster_autoscaler_image_tag[module.eks.cluster_version], "v${module.eks.cluster_version}.0")
        aws_cloudwatch_metrics_iam_role_arn = module.eks_blueprints_addons.aws_cloudwatch_metrics.iam_role_arn
        aws_cloudwatch_metrics_sa = "aws-cloudwatch-metrics"
        enable_argocd = local.enable_argocd
    })
    update = templatefile(
      "${path.module}/templates/create.tftpl",
      {
        cluster_name        = module.eks.cluster_name,
        region              = local.region
        cert_manager_iam_role_arn = module.eks_blueprints_addons.cert_manager.iam_role_arn
        cert_manager_namespace = "cert-manager"
        cluster_autoscaler_iam_role_arn = module.eks_blueprints_addons.cluster_autoscaler.iam_role_arn
        cluster_autoscaler_namespace = "kube-system"
        cluster_autoscaler_sa = "cluster-autoscaler-sa"
        cluster_autoscaler_image_tag = try(local.cluster_autoscaler_image_tag[module.eks.cluster_version], "v${module.eks.cluster_version}.0")
        aws_cloudwatch_metrics_iam_role_arn = module.eks_blueprints_addons.aws_cloudwatch_metrics.iam_role_arn
        aws_cloudwatch_metrics_namespace = "amazon-cloudwatch"
        aws_cloudwatch_metrics_sa = "aws-cloudwatch-metrics"
        enable_argocd = local.enable_argocd
    })
    read = templatefile(
      "${path.module}/templates/create.tftpl",
      {
        cluster_name        = module.eks.cluster_name,
        region              = local.region
        cert_manager_iam_role_arn = module.eks_blueprints_addons.cert_manager.iam_role_arn
        cert_manager_namespace = "cert-manager"
        cluster_autoscaler_iam_role_arn = module.eks_blueprints_addons.cluster_autoscaler.iam_role_arn
        cluster_autoscaler_namespace = "kube-system"
        cluster_autoscaler_sa = "cluster-autoscaler-sa"
        cluster_autoscaler_image_tag = try(local.cluster_autoscaler_image_tag[module.eks.cluster_version], "v${module.eks.cluster_version}.0")
        aws_cloudwatch_metrics_iam_role_arn = module.eks_blueprints_addons.aws_cloudwatch_metrics.iam_role_arn
        aws_cloudwatch_metrics_namespace = "amazon-cloudwatch"
        aws_cloudwatch_metrics_sa = "aws-cloudwatch-metrics"
        enable_argocd = local.enable_argocd
    })
    delete = templatefile(
      "${path.module}/templates/delete.tftpl",
      {
        cluster_name        = module.eks.cluster_name,
        region              = local.region
    })
  }

  depends_on = [
    module.eks
  ]
}


# "user" can be accessed like a normal Terraform map
output "user" {
    value = shell_script.day2ops.output["London"]
}