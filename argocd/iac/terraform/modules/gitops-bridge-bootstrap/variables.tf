/* defaults
{
  argocd = {
    kubeconfig_command           = ""
    argocd_install_script_flags  = "--create-namespace --wait"
    argocd_helm_repository       = "https://argoproj.github.io/argo-helm"
    argocd_version               = "5.38.0"
    argocd_namespace             = "argocd"
    argocd_create_install        = true
    cluster_name                 = "my-cluster"
    argocd_create_cluster_secret = true
    argocd_cluster               = ""
    argocd_create_cluster_secret = true
    argocd_login                 = "kubectl config set-context --current --namespace argocd \nargocd login --port-forward --username admin --password $(argocd admin initial-password | head -1)"
    argocd_bootstrap_app_of_apps = []
  }
}
*/

variable "options" {
  default = {
    argocd = {

    }
  }
}