provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {

  cluster_hub = "cluster-1-cp"
  cluster_hub_environment = "control-plane"

  cluster_spoke_staging = "cluster-1-staging"
  cluster_spoke_staging_environment = "staging"

  cluster_spoke_prod = "cluster-1-prod"
  cluster_spoke_prod_environment = "prod"

  region = "us-west-2"


  addons = {
    #enable_prometheus_adapter                    = true # doesn't required aws resources (ie IAM)
    #enable_gpu_operator                          = true # doesn't required aws resources (ie IAM)
    #enable_kyverno                               = true # doesn't required aws resources (ie IAM)
    #enable_argo_rollouts                         = true # doesn't required aws resources (ie IAM)
    #enable_argo_workflows                        = true # doesn't required aws resources (ie IAM)
    #enable_secrets_store_csi_driver              = true # doesn't required aws resources (ie IAM)
    #enable_secrets_store_csi_driver_provider_aws = true # doesn't required aws resources (ie IAM)
    #enable_kube_prometheus_stack                 = true # doesn't required aws resources (ie IAM)
    #enable_gatekeeper                            = true # doesn't required aws resources (ie IAM)
    #enable_ingress_nginx                         = true # doesn't required aws resources (ie IAM)
    enable_metrics_server                        = true # doesn't required aws resources (ie IAM)
    #enable_vpa                                   = true # doesn't required aws resources (ie IAM)
    #aws_enable_ebs_csi_resources                 = true # generate gp2 and gp3 storage classes for ebs-csi
    #enable_prometheus_adapter                    = true # doesn't required aws resources (ie IAM)
    #enable_gpu_operator                          = true # doesn't required aws resources (ie IAM)
    enable_foo                                   = true # you can add any addon here, make sure to update the gitops repo with the corresponding application set
  }

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = "hub-spoke"
    GithubRepo = "github.com/csantanapr/terraform-gitops-bridge"
  }
}

