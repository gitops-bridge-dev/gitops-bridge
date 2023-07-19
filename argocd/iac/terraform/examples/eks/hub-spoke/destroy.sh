#!/bin/bash

set -x

terraform destroy \
  -target="module.eks_blueprints_addons_hub" \
  -target="module.eks_blueprints_addons_spoke_staging" \
  -target="module.eks_blueprints_addons_spoke_prod" \
  -auto-approve

terraform destroy \
  -target="module.eks_hub" \
  -target="module.eks_spoke_staging" \
  -target="module.eks_spoke_prod" \
  -auto-approve

terraform destroy \
  -target="module.vpc_hub" \
  -target="module.vpc_staging" \
  -target="module.vpc_prod" \
  -auto-approve

terraform destroy -auto-approve
