variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_cert_manager                          = true
    enable_aws_efs_csi_driver                    = true
    enable_aws_fsx_csi_driver                    = true
    enable_aws_cloudwatch_metrics                = true
    enable_aws_privateca_issuer                  = true
    enable_cluster_autoscaler                    = true
    enable_external_dns                          = true
    enable_external_secrets                      = true
    enable_aws_load_balancer_controller          = true
    enable_aws_for_fluentbit                     = true
    enable_aws_node_termination_handler          = true
    enable_karpenter                             = true
    enable_velero                                = true
    enable_aws_gateway_api_controller            = true
    enable_aws_ebs_csi_resources                 = true # generate gp2 and gp3 storage classes for ebs-csi
    enable_aws_secrets_store_csi_driver_provider = true
    enable_argo_rollouts                         = true
    enable_argo_workflows                        = true
    enable_gpu_operator                          = true
    enable_kube_prometheus_stack                 = true
    enable_metrics_server                        = true
    enable_prometheus_adapter                    = true
    enable_secrets_store_csi_driver              = true
    enable_vpa                                   = true
    enable_foo                                   = true # you can add any addon here, make sure to update the gitops repo with the corresponding application set
  }
}
# Addons Git
variable "gitops_addons_org" {
  description = "Git repository org/user contains for addons"
  type        = string
  default     = "https://github.com/gitops-bridge-dev"
}
variable "gitops_addons_repo" {
  description = "Git repository contains for addons"
  type        = string
  default     = "gitops-bridge-argocd-control-plane-template"
}
variable "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  type        = string
  default     = "main"
}
variable "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  type        = string
  default     = ""
}
variable "gitops_addons_path" {
  description = "Git repository path for addons"
  type        = string
  default     = "bootstrap/control-plane/addons"
}
