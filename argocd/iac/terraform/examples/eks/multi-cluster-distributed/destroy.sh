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

# Delete the Ingress/SVC before removing the addons
kubectl_login=$(terraform output -raw configure_kubectl)
$kubectl_login
kubectl delete svc -n argocd argo-cd-argocd-server

terraform destroy -target="module.gitops_bridge_bootstrap" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform destroy -target="module.eks_blueprints_addons" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform destroy -target="module.eks" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform destroy -target="module.vpc" -auto-approve -var-file="workspaces/${env}.tfvars"
terraform destroy -auto-approve -var-file="workspaces/${env}.tfvars"
