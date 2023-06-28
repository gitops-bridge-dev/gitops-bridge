module "argocd" {
  source = "../shell_script"
  name = "gitops-bridge-argocd"
  control_plane = true
}