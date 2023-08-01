variable "argocd" {
  description = "argocd helm options"
  default = {}
}

variable "argocd_create_install" {
  description = "deploy argocd helm"
  default = true
}

variable "argocd_cluster" {
  description = "argocd cluster secret"
  default = null
}

variable "argocd_bootstrap_app_of_apps" {
  description = "argocd app of apps to deploy"
  default = {}
}