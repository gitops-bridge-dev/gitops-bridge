#!/bin/bash

export AWS_PROFILE=default

# Load config from YAML
get_value() {
    yq eval ".config.$1" Pulumi.hub.yaml
}

# Load config from YAML
githubOrg=$(get_value "githubOrg")
githubRepo=$(get_value "githubRepo")
secretPath=$(get_value "secretPath")

# Clone the GitHub repo
git clone "https://github.com/$githubOrg/$githubRepo.git"

# Add EKS cluster to kubeconfig
aws eks --region us-east-1 update-kubeconfig --name hub-cluster --alias hub-cluster

# Install ArgoCD
kubectl create namespace argocd --context hub-cluster
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --context hub-cluster

kubectl apply -f "$githubRepo/$secretPath"

# Echo command to port forward ArgoCD and get admin password
echo "To port forward ArgoCD run: kubectl -n argocd port-forward svc/argocd-server 8080:443 &"
echo "Password can be retrieved by running: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d"