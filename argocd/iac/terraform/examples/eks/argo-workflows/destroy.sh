#!/bin/bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

# Delete the Ingress/SVC before removing the addons
TMPFILE=$(mktemp)
terraform -chdir=$SCRIPTDIR output -raw configure_kubectl > "$TMPFILE"
# check if TMPFILE contains the string "No outputs found"
if [[ ! $(cat $TMPFILE) == *"No outputs found"* ]]; then
  source "$TMPFILE"
  kubectl delete -n argocd applicationset workloads
  kubectl delete -n argocd applicationset cluster-addons
  kubectl delete -n argocd applicationset addons-argocd
  kubectl delete -n argocd applicationset addons-argo-workflows
  kubectl delete svc -n argocd argo-cd-argocd-server
  kubectl delete -n argocd applicationset addons-aws-argo-workflows-ingress
  kubectl delete -n argo-workflows ing --all
fi

terraform destroy -target="module.gitops_bridge_bootstrap" -auto-approve
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
