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
variable "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  type        = string
  default     = "HEAD"
}

variable "gitops_workload_org" {
  description = "Git repository org/user contains for workload"
  type        = string
  default     = "https://github.com/argoproj"
}
variable "gitops_workload_repo" {
  description = "Git repository contains for workload"
  type        = string
  default     = "argocd-example-apps"
}
variable "gitops_workload_path" {
  description = "Git repository path for workload"
  type        = string
  default     = "helm-guestbook"
}
variable "gitops_workload_revision" {
  description = "Git repository revision/branch/ref for workload"
  type        = string
  default     = "HEAD"
}


variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}
variable "kubernetes_version" {
  description = "EKS version"
  type        = string
}
