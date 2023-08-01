#!/bin/bash


if [[ $# -eq 0 ]] ; then
    echo "No arguments supplied"
    echo "Usage: destroy.sh <environment>"
    echo "Example: destroy.sh dev"
    exit 1
fi
env=$1
echo "Destroying $env ..."

set -x

terraform workspace select $env
terraform destroy -target="module.gitops_bridge_bootstrap" -auto-approve -var-file="${env}.tfvars"
terraform destroy -target="module.eks_blueprints_addons" -auto-approve -var-file="${env}.tfvars"
terraform destroy -target="module.eks" -auto-approve -var-file="${env}.tfvars"
terraform destroy -target="module.vpc" -auto-approve -var-file="${env}.tfvars"
terraform destroy -auto-approve -var-file="${env}.tfvars"
