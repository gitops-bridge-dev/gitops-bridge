provider "aws" {
  region = local.region
}

locals {
  name = "cluster-1-staging"
  region = "us-west-2"
  environment = "staging"
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
  argocd_bootstrap_control_plane = "https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap/control-plane/exclude/bootstrap.yaml"
  argocd_bootstrap_workloads = "https://raw.githubusercontent.com/csantanapr/gitops-control-plane/main/bootstrap/workloads/exclude/bootstrap.yaml"
}

################################################################################
# GitOps Bridge
################################################################################

module "gitops_bridge_metadata" {
  source = "../../../modules/gitops-bridge-metadata"

  cluster_name = module.eks.cluster_name
  environment = local.environment
  metadata = module.eks_blueprints_addons.gitops_metadata
  addons = local.addons
  #argocd_remote = true
}

################################################################################
# GitOps Bootstrap: Setup kubeconfig
################################################################################
locals {
  kubeconfig = "/tmp/${module.eks.cluster_name}"
}
resource "shell_script" "kubeconfig" {
  lifecycle_commands {
    create = <<-EOF
      export KUBECONFIG=${local.kubeconfig}
      aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}
      echo "{\"KUBECONFIG\": \"${local.kubeconfig}\"}"
    EOF
    read = <<-EOF
      export KUBECONFIG=${local.kubeconfig}
      aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name}
      echo "{\"KUBECONFIG\": \"${local.kubeconfig}\"}"
    EOF
    delete = "echo gitops ftw!"
  }
}

################################################################################
# GitOps Bootstrap: Install GitOps engine
################################################################################
locals {
  argocd_cluster_manifest = "${path.module}/argocd.yaml"
  argocd_helm_repository = "https://argoproj.github.io/argo-helm"
  argocd_version = "5.38.0"
  argocd_namespace = "argocd"
  argocd_install = true
  argocd_install_script = <<-EOF
    helm repo list  | grep argo-helm || helm repo add argo "${local.argocd_helm_repository}"
    helm repo update
    if ! helm list -n "${local.argocd_namespace}" --filter="argo-cd" | grep argo-cd; then
      helm install argo-cd argo/argo-cd --version "${local.argocd_version}" --namespace "${local.argocd_namespace}" --create-namespace --wait
    fi
    echo "{\"NAMESPACE\": \"${local.argocd_namespace}\"}"
  EOF
}

resource "local_file" "argocd_yaml" {
  content  = yamlencode(module.gitops_bridge_metadata.argocd)
  filename = local.argocd_cluster_manifest
}

resource "shell_script" "argocd" {
  count = local.argocd_install ? 1 : 0
  lifecycle_commands {
    create = local.argocd_install_script
    update = local.argocd_install_script
    delete = "echo gitops ftw!"
  }
  environment = {
    KUBECONFIG = resource.shell_script.kubeconfig.output["KUBECONFIG"]
  }
}

################################################################################
# GitOps Bootstrap: Store cluster metadata inside cluster
################################################################################
locals {
  argocd_create_cluster = true
}
resource "shell_script" "argocd_create_cluster" {
  count = local.argocd_create_cluster ? 1 : 0
  lifecycle_commands {
    create = <<-EOF
      kubectl apply -n $NAMESPACE -f "${local.argocd_cluster_manifest}"
    EOF
    update = <<-EOF
      kubectl apply -n $NAMESPACE -f "${local.argocd_cluster_manifest}"
    EOF
    delete = <<-EOF
      kubectl delete -n $NAMESPACE -f "${local.argocd_cluster_manifest}"
    EOF
  }
  environment = {
    NAMESPACE = resource.shell_script.argocd[0].output["NAMESPACE"]
    KUBECONFIG = resource.shell_script.kubeconfig.output["KUBECONFIG"]
  }
}


################################################################################
# GitOps Bootstrap: Create Apps or App
################################################################################
locals {
  argocd_bootstrap_manifests = [
    local.argocd_bootstrap_control_plane,
    local.argocd_bootstrap_workloads
  ]
  argocd_bootstrap = true
}
resource "shell_script" "argocd_bootstrap" {
  for_each = local.argocd_bootstrap ? toset( local.argocd_bootstrap_manifests ): toset([])
  lifecycle_commands {
    create = <<-EOF
      kubectl apply -n $NAMESPACE -f "${each.value}"
    EOF
    update = <<-EOF
      kubectl apply -n $NAMESPACE -f "${each.value}"
    EOF
    delete = "echo gitops ftw!"
  }
  environment = {
    NAMESPACE = resource.shell_script.argocd[0].output["NAMESPACE"]
    KUBECONFIG = resource.shell_script.kubeconfig.output["KUBECONFIG"]
  }
  depends_on = [ shell_script.argocd_create_cluster ]
}


################################################################################
# Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source = "../../../../../../terraform-aws-eks-blueprints-addons"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id            = module.vpc.vpc_id

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
  }

  #enable_aws_efs_csi_driver                    = true
  #enable_aws_fsx_csi_driver                    = true
  #enable_aws_cloudwatch_metrics = true
  #enable_aws_privateca_issuer                  = true
  enable_cert_manager       = true
  #enable_cluster_autoscaler = true
  #enable_external_dns                          = true
  #external_dns_route53_zone_arns = ["arn:aws:route53:::hostedzone/Z123456789"]
  #enable_external_secrets                      = true
  enable_aws_load_balancer_controller = true
  #enable_aws_for_fluentbit            = true
  #enable_fargate_fluentbit            = true
  #enable_aws_node_termination_handler   = true
  #aws_node_termination_handler_asg_arns = [for asg in module.eks.self_managed_node_groups : asg.autoscaling_group_arn]
  #enable_karpenter = true
  #enable_velero = true
  ## An S3 Bucket ARN is required. This can be declared with or without a Suffix.
  #velero = {
  #  s3_backup_location = "${module.velero_backup_s3_bucket.s3_bucket_arn}/backups"
  #}
  #enable_aws_gateway_api_controller = true

  tags = local.tags
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.14"

  role_name_prefix = "${local.name}-ebs-csi-driver-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}


################################################################################
# Cluster
################################################################################
data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/csantanapr/terraform-gitops-bridge"
  }
}

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.name
  cluster_version                = "1.27"
  cluster_endpoint_public_access = true


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.large"]

      min_size     = 3
      max_size     = 10
      desired_size = 3
    }
  }
  # EKS Addons
  cluster_addons = {
    vpc-cni = {
      # Specify the VPC CNI addon should be deployed before compute to ensure
      # the addon is configured before data plane compute resources are created
      # See README for further details
      before_compute = true
      most_recent    = true # To ensure access to the latest settings provided
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
