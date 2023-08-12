variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}
variable "kubernetes_version" {
  description = "EKS version"
  default     = "1.27"
}
