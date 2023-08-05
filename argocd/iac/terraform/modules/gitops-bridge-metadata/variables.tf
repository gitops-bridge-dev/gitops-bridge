variable "cluster_name" {
  default = "my-cluster"
}
variable "environment" {
  default = "dev"
}
variable "metadata" {
  default = {}
}
variable "addons" {
  default = {}
}
variable "argocd" {
  default = {}
}
variable "fluxcd" {
  default = {}
}

