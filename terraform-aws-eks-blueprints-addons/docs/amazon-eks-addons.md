# Amazon EKS Add-ons

The Amazon EKS add-on implementation is generic and can be used to deploy any add-on supported by the EKS API; either native EKS addons or third party add-ons supplied via the AWS Marketplace.

See the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) for more details on EKS addon-ons, including the list of [Amazon EKS add-ons from Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html#workloads-add-ons-available-eks), as well as [Additional Amazon EKS add-ons from independent software vendors](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html#workloads-add-ons-available-vendors).

## Architecture Support

The Amazon EKS provided add-ons listed below support both `x86_64/amd64` and `arm64` architectures. Third party add-ons that are available via the AWS Marketplace will vary based on the support provided by the add-on vendor. No additional changes are required to add-on configurations when switching between `x86_64/amd64` and `arm64` architectures; Amazon EKS add-ons utilize multi-architecture container images to support this functionality.

| Add-on | x86_64/amd64 | arm64 |
|-------|:------:|:-----:|
| `vpc-cni` | ✅ | ✅ |
| `aws-ebs-csi-driver` | ✅ | ✅ |
| `coredns` | ✅ | ✅ |
| `kube-proxy` | ✅ | ✅ |
| `adot` | ✅ | ✅ |
| `aws-guardduty-agent` | ✅ | ✅ |

## Usage

The Amazon EKS add-ons are provisioned via a generic interface behind the `eks_addons` argument which accepts a map of add-on configurations. The generic interface for an add-on is defined below for reference:

```hcl
module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  # ... truncated for brevity

  eks_addons = {
    <key> = {
      name = string # Optional - <key> is used if `name` is not set

      most_recent          = bool
      addon_version        = string # overrides `most_recent` if set
      configuration_values = string # JSON string

      preserve                    = bool # defaults to `true`
      resolve_conflicts_on_create = string # defaults to `OVERWRITE`
      resolve_conflicts_on_update = string # defaults to `OVERWRITE`

      timeouts = {
        create = string # optional
        update = string # optional
        delete = string # optional
      }

      tags = map(string)
    }
  }
}
```

### Example

```hcl
module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  # ... truncated for brevity

  eks_addons = {
    # Amazon EKS add-ons
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

    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }

    kube-proxy = {}

    # Third party add-ons via AWS Marketplace
    kubecost_kubecost = {
      most_recent = true
    }

    teleport_teleport = {
      most_recent = true
    }
  }
}
```

### Configuration Values

You can supply custom configuration values to each addon via the `configuration_values` argument of the add-on definition. The value provided must be a JSON encoded string and adhere to the JSON scheme provided by the version of the add-on. You can view this schema using the awscli by supplying the add-on name and version to the `describe-addon-configuration` command:

```sh
aws eks describe-addon-configuration \
 --addon-name coredns \
 --addon-version v1.8.7-eksbuild.2 \
 --query 'configurationSchema' \
 --output text | jq
```

Which returns the formatted JSON schema like below:

```json
{
  "$ref": "#/definitions/Coredns",
  "$schema": "http://json-schema.org/draft-06/schema#",
  "definitions": {
    "Coredns": {
      "additionalProperties": false,
      "properties": {
        "computeType": {
          "type": "string"
        },
        "corefile": {
          "description": "Entire corefile contents to use with installation",
          "type": "string"
        },
        "nodeSelector": {
          "additionalProperties": {
            "type": "string"
          },
          "type": "object"
        },
        "replicaCount": {
          "type": "integer"
        },
        "resources": {
          "$ref": "#/definitions/Resources"
        }
      },
      "title": "Coredns",
      "type": "object"
    },
    "Limits": {
      "additionalProperties": false,
      "properties": {
        "cpu": {
          "type": "string"
        },
        "memory": {
          "type": "string"
        }
      },
      "title": "Limits",
      "type": "object"
    },
    "Resources": {
      "additionalProperties": false,
      "properties": {
        "limits": {
          "$ref": "#/definitions/Limits"
        },
        "requests": {
          "$ref": "#/definitions/Limits"
        }
      },
      "title": "Resources",
      "type": "object"
    }
  }
}
```

You can supply the configuration values to the add-on by passing a map of the values wrapped in the `jsonencode()` function as shown below:

```hcl
module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"

  # ... truncated for brevity

  eks_addons = {
    coredns = {
      most_recent = true

      configuration_values = jsonencode({
        replicaCount = 4
        resources = {
          limits = {
            cpu    = "100m"
            memory = "150Mi"
          }
          requests = {
            cpu    = "100m"
            memory = "150Mi"
          }
        }
      })
    }
  }
}
```
