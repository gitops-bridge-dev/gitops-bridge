provider "aws" {
  region = local.region
}
data "aws_availability_zones" "available" {}


provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
    command     = "aws"
  }
  load_config_file  = false
  apply_retry_count = 15
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", local.region]
  }
}

locals {
  name        = "ex-${replace(basename(path.cwd), "_", "-")}"
  environment = "dev"
  region      = "us-west-2"

  aws_addons = {
    enable_cert_manager                          = true
    enable_aws_efs_csi_driver                    = true
    enable_aws_fsx_csi_driver                    = true
    enable_aws_cloudwatch_metrics                = true
    enable_aws_privateca_issuer                  = true
    enable_cluster_autoscaler                    = true
    enable_external_dns                          = true
    enable_external_secrets                      = true
    enable_aws_load_balancer_controller          = true
    enable_fargate_fluentbit                     = true
    enable_aws_for_fluentbit                     = true
    enable_aws_node_termination_handler          = true
    enable_karpenter                             = true
    enable_velero                                = true
    enable_aws_gateway_api_controller            = true
    enable_aws_ebs_csi_resources                 = true # generate gp2 and gp3 storage classes for ebs-csi
    enable_aws_secrets_store_csi_driver_provider = true
  }
  oss_addons = {
    enable_argo_rollouts  = true
    enable_argo_workflows = true
    #enable_cluster_proportional_autoscaler      = true
    enable_gatekeeper   = true
    enable_gpu_operator = true
    #enable_ingress_nginx                        = true
    enable_kyverno                  = true
    enable_kube_prometheus_stack    = true
    enable_metrics_server           = true
    enable_prometheus_adapter       = true
    enable_secrets_store_csi_driver = true
    enable_vpa                      = true
    enable_foo                      = true # you can add any addon here, make sure to update the gitops repo with the corresponding application set
  }
  addons = merge(local.aws_addons, local.oss_addons)

  addons_metadata = merge({
    aws_vpc_id = module.vpc.vpc_id # Only required when enabling the aws_gateway_api_controller addon
    },
    module.eks_blueprints_addons.gitops_metadata
  )

  argocd_bootstrap_app_of_apps = {
    addons    = file("${path.module}/bootstrap/addons.yaml")
    workloads = file("${path.module}/bootstrap/workloads.yaml")
  }

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/csantanapr/terraform-gitops-bridge"
  }
}

################################################################################
# GitOps Bridge: Metadata
################################################################################
module "gitops_bridge_metadata" {
  source = "../../../../modules/gitops-bridge-metadata"

  cluster_name = module.eks.cluster_name
  environment  = local.environment
  metadata     = local.addons_metadata
  addons       = local.addons
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source = "../../../../modules/gitops-bridge-bootstrap"

  argocd_cluster               = module.gitops_bridge_metadata.argocd
  argocd_bootstrap_app_of_apps = local.argocd_bootstrap_app_of_apps
}


################################################################################
# EKS Blueprints Addons
################################################################################
module "eks_blueprints_addons" {
  source = "github.com/csantanapr/terraform-aws-eks-blueprints-addons?ref=gitops-bridge-v2"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # Using GitOps Bridge
  create_kubernetes_resources = false

  # EKS Blueprints Addons
  enable_cert_manager                 = try(local.aws_addons.enable_cert_manager, false)
  enable_aws_efs_csi_driver           = try(local.aws_addons.enable_aws_efs_csi_driver, false)
  enable_aws_fsx_csi_driver           = try(local.aws_addons.enable_aws_fsx_csi_driver, false)
  enable_aws_cloudwatch_metrics       = try(local.aws_addons.enable_aws_cloudwatch_metrics, false)
  enable_aws_privateca_issuer         = try(local.aws_addons.enable_aws_privateca_issuer, false)
  enable_cluster_autoscaler           = try(local.aws_addons.enable_cluster_autoscaler, false)
  enable_external_dns                 = try(local.aws_addons.enable_external_dns, false)
  enable_external_secrets             = try(local.aws_addons.enable_external_secrets, false)
  enable_aws_load_balancer_controller = try(local.aws_addons.enable_aws_load_balancer_controller, false)
  enable_fargate_fluentbit            = try(local.aws_addons.enable_fargate_fluentbit, false)
  enable_aws_for_fluentbit            = try(local.aws_addons.enable_aws_for_fluentbit, false)
  enable_aws_node_termination_handler = try(local.aws_addons.enable_aws_node_termination_handler, false)
  enable_karpenter                    = try(local.aws_addons.enable_karpenter, false)
  enable_velero                       = try(local.aws_addons.enable_velero, false)
  enable_aws_gateway_api_controller   = try(local.aws_addons.enable_aws_gateway_api_controller, false)

  external_dns_route53_zone_arns = ["arn:aws:route53:::hostedzone/Z123456789"] # fake value for testing
  #external_dns_route53_zone_arns = [data.aws_route53_zone.domain_name.arn]
  aws_for_fluentbit = {
    s3_bucket_arns = [
      module.velero_backup_s3_bucket.s3_bucket_arn,
      "${module.velero_backup_s3_bucket.s3_bucket_arn}/logs/*"
    ]
  }
  aws_node_termination_handler_asg_arns = [for asg in module.eks.self_managed_node_groups : asg.autoscaling_group_arn]
  ## An S3 Bucket ARN is required. This can be declared with or without a Suffix.
  velero = {
    s3_backup_location = "${module.velero_backup_s3_bucket.s3_bucket_arn}/backups"
  }

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
    coredns = {
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {}
    /* adot needs to be installed after cert-manager is installed with gitops, uncomment once cluster addons are deployed
    adot = {
      most_recent              = true
      service_account_role_arn = module.adot_irsa.iam_role_arn
    }
    */
    aws-guardduty-agent = {}
  }

  tags = local.tags
}

/*
data "aws_route53_zone" "domain_name" {
  name         = "example.com"
  private_zone = false
}
*/


################################################################################
# EKS Cluster
################################################################################
#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.13"

  cluster_name                   = local.name
  cluster_version                = "1.26"
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  manage_aws_auth_configmap = true

  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 10
      desired_size = 3
    }
  }

  self_managed_node_groups = {
    default = {
      instance_type = "m5.large"

      min_size     = 2
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


module "velero_backup_s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket_prefix = "${local.name}-"

  # Allow deletion of non-empty bucket
  # NOTE: This is enabled for example usage only, you should not enable this for production workloads
  force_destroy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  acl = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    status     = true
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

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

module "adot_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.20"

  role_name_prefix = "${local.name}-adot-"

  role_policy_arns = {
    prometheus = "arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess"
    xray       = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
    cloudwatch = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["opentelemetry-operator-system:opentelemetry-operator"]
    }
  }

  tags = local.tags
}


resource "aws_security_group" "guardduty" {
  name        = "guardduty_vpce_allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_vpc_endpoint" "guardduty" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${local.region}.guardduty-data"
  subnet_ids          = module.vpc.private_subnets
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.guardduty.id]
  private_dns_enabled = true

  tags = local.tags
}
