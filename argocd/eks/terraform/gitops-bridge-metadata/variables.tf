variable "cluster_name" {
  default = null
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


variable "options" {
  default = {}
}
variable "enable_argocd" {
  default = true
}

