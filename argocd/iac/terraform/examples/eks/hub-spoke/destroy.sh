#!/bin/bash

set -x

terraform destroy -target="module.eks_blueprints_addons_hub" -auto-approve
terraform destroy -target="module.eks_hub" -auto-approve

terraform destroy -target="module.eks_blueprints_addons_spoke_staging" -auto-approve
terraform destroy -target="module.eks_spoke_staging" -auto-approve

terraform destroy -target="module.eks_blueprints_addons_spoke_prod" -auto-approve
terraform destroy -target="module.eks_spoke_prod" -auto-approve

terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
