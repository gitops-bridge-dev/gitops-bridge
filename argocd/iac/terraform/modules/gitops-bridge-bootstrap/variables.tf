variable "kubeconfig_command" {
    default = ""
}

variable "cluster_name" {

}


variable "argocd_create_install" {
  default = true
}
variable "argocd_helm_repository" {
  default = "https://argoproj.github.io/argo-helm"
}
variable "argocd_version" {
  default = "5.38.0"
}
variable "argocd_namespace" {
  default = "argocd"
}


variable "argocd_create_cluster_secret" {
  default = true
}
variable "argocd_cluster" {
  default = ""
}


variable "argocd_create_app_of_apps" {
  default = true
}
variable "argocd_login" {
 default = "kubectl config set-context --current --namespace argocd \nargocd login --port-forward --username admin --password $(argocd admin initial-password | head -1)"
}
variable "argocd_bootstrap_app_of_apps" {
  default = []
}
