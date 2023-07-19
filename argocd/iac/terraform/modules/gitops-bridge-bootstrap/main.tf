################################################################################
# Install ArgoCD
################################################################################
locals {
  argocd_install_script = <<-EOF
    set -x
    ${var.kubeconfig_command}
    helm repo add argo "${var.argocd_helm_repository}"
    helm repo update
    helm upgrade --install argo-cd argo/argo-cd --version "${var.argocd_version}" --namespace "${var.argocd_namespace}" --create-namespace --wait
    echo "{\"namespace\": \"${var.argocd_namespace}\"}"
  EOF
}

resource "shell_script" "argocd_install" {
  count = var.argocd_create_install ? 1 : 0
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
  argocd_cluster_secret_script = <<-EOF
    set -x
    ${var.kubeconfig_command}
    kubectl apply -f ${local.argocd_cluster_manifest}
    echo "{\"cluster\": \"${local.argocd_cluster_manifest}\"}"
  EOF
  argocd_cluster_manifest = "${path.root}/.terraform/tmp/${var.cluster_name}.yaml"
}

resource "local_file" "argocd_cluster_manifest" {
  content  = yamlencode(var.argocd_cluster)
  filename = local.argocd_cluster_manifest
}

resource "shell_script" "argocd_cluster" {
  count = var.argocd_create_cluster_secret ? 1 : 0
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
resource "shell_script" "argocd_app_of_apps" {
  for_each = toset(var.argocd_bootstrap_app_of_apps)
  lifecycle_commands {
    create = <<-EOF
        set -x
        ${var.kubeconfig_command}
        ${var.argocd_login}
        ${each.key}
        echo "{\"app\": \"${each.key}\"}"
    EOF
    update = <<-EOF
        set -x
        ${var.kubeconfig_command}
        ${var.argocd_login}
        ${each.key}
        echo "{\"app\": \"${each.key}\"}"
    EOF
    /*
    read = <<-EOF
        set -x
        ${var.kubeconfig_command}
        ${var.argocd_login}
        ${each.key}
        echo "{\"app\": \"${each.key}\"}"
    EOF
    */

    delete = "echo gitops ftw!"
  }
  depends_on = [ shell_script.argocd_cluster ]
}
