variable "gitops_url" {
  description = "Git repository contains for addons"
  default     = "https://github.com/gitops-bridge-dev/gitops-bridge-argocd-control-plane-template"
}
variable "gitops_revision" {
  description = "Git repository revision/branch/ref for addons"
  default     = "HEAD"
}
variable "gitops_path" {
  description = "Git repository path for addons"
  default     = "bootstrap/control-plane/addons"
}
