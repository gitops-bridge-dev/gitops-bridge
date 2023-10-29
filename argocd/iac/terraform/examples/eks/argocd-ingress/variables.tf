variable "domain_name" {
  description = "Route 53 domain name"
  type        = string
}
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
    enable_external_dns = true
    enable_aws_load_balancer_controller               = true
    enable_aws_argocd_ingress = true
  }
}
variable "gitops_addons_org" {
  description = "Git repository org/user contains for addons"
  default     = "https://github.com/gitops-bridge-dev"
}
variable "gitops_addons_repo" {
  description = "Git repository contains for addons"
  default     = "gitops-bridge-argocd-control-plane-template"
}
variable "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  default     = ""
}
variable "gitops_addons_path" {
  description = "Git repository path for addons"
  default     = "bootstrap/control-plane/addons"
}
variable "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  default     = "HEAD"
}
