################################################################################
# Globals
################################################################################

################################################################################
# Install ArgoCD
################################################################################
locals {
  argocd_helm_name = try(var.options.argocd.argocd_helm_name,"argo-cd")
  argocd_helm_chart = try(var.options.argocd.argocd_helm_chart,"argo-cd")
  argocd_helm_repository = try(var.options.argocd.argocd_helm_repository, "https://argoproj.github.io/argo-helm")
  argocd_version = try(var.options.argocd.argocd_version,"5.38.0")
  argocd_namespace = try(var.options.argocd.argocd_namespace,"argocd")
  argcd_helm_wait  = try(var.options.argocd.wait, true)
}

resource "helm_release" "argocd" {
  count = try(var.options.argocd.argocd_create_install, true) ? 1 : 0

  name                       = local.argocd_helm_name
  repository                 = local.argocd_helm_repository
  chart                      = local.argocd_helm_chart
  version                    = local.argocd_version
  namespace                  = local.argocd_namespace
  wait                       = local.argcd_helm_wait
  description                = try(var.options.argocd.description, "A Helm chart to install the ArgoCD")
  create_namespace           = try(var.options.argocd.create_namespace, true)

  values                     = try(var.options.argocd.values, [])
  timeout                    = try(var.options.argocd.timeout, null)
  repository_key_file        = try(var.options.argocd.repository_key_file, null)
  repository_cert_file       = try(var.options.argocd.repository_cert_file, null)
  repository_ca_file         = try(var.options.argocd.repository_ca_file, null)
  repository_username        = try(var.options.argocd.repository_username, null)
  repository_password        = try(var.options.argocd.repository_password, null)
  devel                      = try(var.options.argocd.devel, null)
  verify                     = try(var.options.argocd.verify, null)
  keyring                    = try(var.options.argocd.keyring, null)
  disable_webhooks           = try(var.options.argocd.disable_webhooks, null)
  reuse_values               = try(var.options.argocd.reuse_values, null)
  reset_values               = try(var.options.argocd.reset_values, null)
  force_update               = try(var.options.argocd.force_update, null)
  recreate_pods              = try(var.options.argocd.recreate_pods, null)
  cleanup_on_fail            = try(var.options.argocd.cleanup_on_fail, null)
  max_history                = try(var.options.argocd.max_history, null)
  atomic                     = try(var.options.argocd.atomic, null)
  skip_crds                  = try(var.options.argocd.skip_crds, null)
  render_subchart_notes      = try(var.options.argocd.render_subchart_notes, null)
  disable_openapi_validation = try(var.options.argocd.disable_openapi_validation, null)

  wait_for_jobs              = try(var.options.argocd.wait_for_jobs, null)
  dependency_update          = try(var.options.argocd.dependency_update, null)
  replace                    = try(var.options.argocd.replace, null)
  lint                       = try(var.options.argocd.lint, null)

  dynamic "postrender" {
    for_each = length(try(var.options.argocd.postrender,{})) > 0 ? [var.options.argocd.postrender] : []

    content {
      binary_path = postrender.value.binary_path
      args        = try(postrender.value.args, null)
    }
  }

  dynamic "set" {
    for_each = try(var.options.argocd.set,[])

    content {
      name  = set.value.name
      value = set.value.value
      type  = try(set.value.type, null)
    }
  }

  dynamic "set_sensitive" {
    for_each = try(var.options.argocd.set_sensitive, [])

    content {
      name  = set_sensitive.value.name
      value = set_sensitive.value.value
      type  = try(set_sensitive.value.type, null)
    }
  }

}

################################################################################
# Register ArgoCD Cluster Secret
################################################################################
resource "kubectl_manifest" "cluster" {
  count = try(var.options.argocd.argocd_create_cluster_secret,true) ? 1 : 0

  yaml_body = yamlencode(var.options.argocd.argocd_cluster)

  depends_on = [ helm_release.argocd ]
}


################################################################################
# Create App of Apps
################################################################################
resource "kubectl_manifest" "bootstrap" {
  for_each = try(var.options.argocd.argocd_bootstrap_app_of_apps,{})

  yaml_body = each.value

  depends_on = [ resource.kubectl_manifest.cluster ]
}

