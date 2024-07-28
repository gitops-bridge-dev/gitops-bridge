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
  kubectl scale deploy -n game-2048 game-2048 --replicas=0
  kubectl scale deploy -n gatekeeper-system gatekeeper-audit --replicas=0
  kubectl scale deploy -n gatekeeper-system gatekeeper-controller-manager --replicas=0
  kubectl scale deploy -n kube-system metrics-server --replicas=0
  kubectl delete nodes -l karpenter.sh/registered=true
  kubectl delete -n game-2048 ing game-2048
  kubectl delete -n argocd svc argocd-server
  sleep 60
fi

terraform destroy -target="module.gitops_bridge_bootstrap" -auto-approve
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
