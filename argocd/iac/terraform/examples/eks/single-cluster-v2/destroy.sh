#!/bin/bash

set -uo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/../..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

scale_down_karpenter_nodes() {
  # Get all nodes with the label karpenter.sh/registered=true
  nodes=$(kubectl get nodes -l karpenter.sh/registered=true -o jsonpath='{.items[*].metadata.name}')

  # Iterate over each node
  for node in $nodes; do
    # Get all pods running on the current node
    pods=$(kubectl get pods --all-namespaces --field-selector spec.nodeName=$node -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}')

    # Iterate over each pod
    while IFS= read -r pod; do
      namespace=$(echo $pod | awk '{print $1}')
      pod_name=$(echo $pod | awk '{print $2}')

      # Get the owner references of the pod
      owner_refs=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.metadata.ownerReferences[*]}')

      # Check if the owner is a ReplicaSet (which is part of a deployment) or a StatefulSet and scale down
      if echo $owner_refs | grep -q "ReplicaSet"; then
      replicaset_name=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.metadata.ownerReferences[?(@.kind=="ReplicaSet")].name}')
      deployment_name=$(kubectl get replicaset $replicaset_name -n $namespace -o jsonpath='{.metadata.ownerReferences[?(@.kind=="Deployment")].name}')
      if [[ $(kubectl get deployment $deployment_name -n $namespace -o jsonpath='{.spec.replicas}') -gt 0 ]]; then
        kubectl scale deployment $deployment_name -n $namespace --replicas=0
      fi
      elif echo $owner_refs | grep -q "StatefulSet"; then
      statefulset_name=$(kubectl get pod $pod_name -n $namespace -o jsonpath='{.metadata.ownerReferences[?(@.kind=="StatefulSet")].name}')
      if [[ $(kubectl get statefulset $statefulset_name -n $namespace -o jsonpath='{.spec.replicas}') -gt 0 ]]; then
        kubectl scale statefulset $statefulset_name -n $namespace --replicas=0
      fi
      fi
    done <<< "$pods"
  done

  # Loop through each node and delete it
  for node in $nodes; do
      echo "Deleting node: $node"
      kubectl delete node $node
  done
  # do a final check to make sure the nodes are gone, loop sleep 60 in between checks
  nodes=$(kubectl get nodes -l karpenter.sh/registered=true -o jsonpath='{.items[*].metadata.name}')
  while [[ ! -z $nodes ]]; do
    echo "Waiting for nodes to be deleted: $nodes"
    sleep 60
    nodes=$(kubectl get nodes -l karpenter.sh/registered=true -o jsonpath='{.items[*].metadata.name}')
  done


}

# We must destroy the karpenter node before we destroy the EKS cluster

exit 0

# Delete the Ingress/SVC before removing the addons
TMPFILE=$(mktemp)
terraform -chdir=$SCRIPTDIR output -raw configure_kubectl > "$TMPFILE"
# check if TMPFILE contains the string "No outputs found"
if [[ ! $(cat $TMPFILE) == *"No outputs found"* ]]; then
  source "$TMPFILE"
  scale_down_karpenter_nodes
  kubectl delete ing -A --all
  # delete all the kuberneters service of type LoadBalancer, without using jq
  kubectl get svc --all-namespaces -o json | grep -E '"type": "LoadBalancer"' | awk '{print "echo kubectl delete svc " $1 " -n " $2}' | bash
  sleep 60
fi

terraform destroy -target="module.gitops_bridge_bootstrap" -auto-approve
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve

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
  sleep 60
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
  sleep 60
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
  sleep 60
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
  sleep 60
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
  sleep 60
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
  sleep 60
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
  sleep 60
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



