#!/bin/bash

set -x
terraform destroy -target="shell_script.argocd_create_cluster" -auto-approve
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
