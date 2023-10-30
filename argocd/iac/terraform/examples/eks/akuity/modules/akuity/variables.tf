variable "argocd_admin_password" {
  type        = string
  description = "The password to use for the `admin` Argo CD user."
}
variable "cluster" {
  description = "argocd cluster secret"
  type        = any
}
variable "repo_credential_secrets" {
  description = "repo_credential_secrets"
  type        = any
  default =  {}
}


