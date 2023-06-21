provider "aws" {
  region = local.region
}

locals {
  name   = "ex-${replace(basename(path.cwd), "_", "-")}"
  region = "us-west-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/csantanapr/terraform-gitops-bridge"
  }
}


resource "shell_script" "day2ops" {

  lifecycle_commands {
    create = templatefile(
      "${path.module}/templates/create.tftpl",
      {
        cluster_name        = module.eks.cluster_name,
        region              = local.region
    })
    delete = templatefile(
      "${path.module}/templates/delete.tftpl",
      {
        cluster_name        = module.eks.cluster_name,
        region              = local.region
    })
    update = templatefile(
      "${path.module}/templates/create.tftpl",
      {
        cluster_name        = module.eks.cluster_name,
        region              = local.region
    })
    read = templatefile(
      "${path.module}/templates/create.tftpl",
      {
        cluster_name        = module.eks.cluster_name,
        region              = local.region
    })
  }

  depends_on = [
    module.eks
  ]
}


# "user" can be accessed like a normal Terraform map
output "user" {
    value = shell_script.day2ops.output["London"]
}