################################################################################
# Globals
################################################################################
locals {
  argocd_kubeconfig_command = try(var.options.argocd.kubeconfig_command,"")
}

################################################################################
# Install ArgoCD
################################################################################
locals {
  argocd_install_script = <<-EOF
    set -x
    ${local.argocd_kubeconfig_command}
    helm repo add argo "${local.argocd_helm_repository}"
    helm repo update
    helm upgrade --install argo-cd argo/argo-cd --version "${local.argocd_version}" --namespace "${local.argocd_namespace}" ${local.argocd_install_script_flags}
    echo "{\"namespace\": \"${local.argocd_namespace}\"}"
  EOF
  argocd_install_script_flags = try(var.options.argocd.argocd_install_script_flags,"--create-namespace --wait")
  argocd_helm_repository = try(var.options.argocd.argocd_helm_repository, "https://argoproj.github.io/argo-helm")
  argocd_version = try(var.options.argocd.argocd_version,"5.38.0")
  argocd_namespace = try(var.options.argocd.argocd_namespace,"argocd")
}

resource "shell_script" "argocd_install" {
  count = try(var.options.argocd.argocd_create_install, true) ? 1 : 0
  lifecycle_commands {
    create = local.argocd_install_script
    update = local.argocd_install_script
    //read = local.argocd_install_script
    delete = "echo gitops ftw!"
  }
}

################################################################################
# Register ArgoCD Cluster Secret
################################################################################
locals {
  argocd_cluster_command = try(var.options.argocd.argocd_cluster_command,"kubectl apply -f ${local.argocd_cluster_manifest}")
  argocd_cluster_secret_script = <<-EOF
    set -x
    ${local.argocd_kubeconfig_command}
    ${local.argocd_cluster_command}
  EOF
  argocd_cluster_manifest = "${path.root}/.terraform/tmp/${try(var.options.argocd.cluster_name,"my-cluster")}.yaml"
}

resource "local_file" "argocd_cluster_manifest" {
  count = try(var.options.argocd.argocd_create_cluster_secret,true) ? 1 : 0

  content  = yamlencode(try(var.options.argocd.argocd_cluster,""))
  filename = local.argocd_cluster_manifest
}

resource "shell_script" "argocd_cluster" {
  count = try(var.options.argocd.argocd_create_cluster_secret,true) ? 1 : 0
  lifecycle_commands {
    create = local.argocd_cluster_secret_script
    update = local.argocd_cluster_secret_script
    //read = local.argocd_cluster_secret_script
    delete = "echo gitops ftw!"
  }
  depends_on = [ shell_script.argocd_install, local_file.argocd_cluster_manifest ]
}

################################################################################
# Create App of Apps
################################################################################
locals {
  argocd_login = try(var.options.argocd.argocd_login,"kubectl config set-context --current --namespace argocd \nargocd login --port-forward --username admin --password $(argocd admin initial-password | head -1)")
  argocd_bootstrap_script = <<-EOF
    set -x
    ${local.argocd_kubeconfig_command}
    ${local.argocd_login}
    ${try(var.options.argocd.argocd_bootstrap_app_of_apps,"")}
  EOF
}
resource "shell_script" "argocd_app_of_apps" {
  count = try(var.options.argocd.argocd_create_app_of_apps,true) ? 1 : 0
  lifecycle_commands {
    create = local.argocd_bootstrap_script
    update = local.argocd_bootstrap_script
    //read = local.argocd_bootstrap_script
    delete = "echo gitops ftw!"
  }
  depends_on = [ shell_script.argocd_cluster ]
}
