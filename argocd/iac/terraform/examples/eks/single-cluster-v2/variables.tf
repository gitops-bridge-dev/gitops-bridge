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
  default     = "1.30"
}
variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}
variable "tenant" {
  description = "Tenant for addon stacks"
  type        = string
  default     = "tenant1" # make it empty string if you don't want to use tenant
}

variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_aws_load_balancer_controller = true
    enable_aws_ebs_csi_resources        = true # generate gp2 and gp3 storage classes for ebs-csi
    enable_metrics_server               = true
    enable_gatekeeper                   = true
    enable_karpenter                   = true
    enable_argocd                       = true
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
  default     = "gitops-bridge"
}
variable "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  type        = string
  default     = "single-cluster-v2"
}
variable "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  type        = string
  default     = "argocd/iac/terraform/examples/eks/single-cluster-v2/gitops/"
}
variable "gitops_addons_path" {
  description = "Git repository path for addons"
  type        = string
  default     = ""
}

# Workloads Git
variable "gitops_workload_org" {
  description = "Git repository org/user contains for workload"
  type        = string
  default     = "https://github.com/gitops-bridge-dev"
}
variable "gitops_workload_repo" {
  description = "Git repository contains for workload"
  type        = string
  default     = "gitops-bridge"
}
variable "gitops_workload_revision" {
  description = "Git repository revision/branch/ref for workload"
  type        = string
  default     = "single-cluster-v2"
}
variable "gitops_workload_basepath" {
  description = "Git repository base path for workload"
  type        = string
  default     = "argocd/iac/terraform/examples/eks/single-cluster-v2/gitops/workloads/"
}
variable "gitops_workload_path" {
  description = "Git repository path for workload"
  type        = string
  default     = "single-cluster-v2/k8s"
}

variable "enable_addon_selector" {
  description = "select addons using cluster selector"
  type        = bool
  default     = false
}