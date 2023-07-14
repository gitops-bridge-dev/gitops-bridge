# Terraform GitOps Bridge for ArgoCD on Amazon EKS

Examples

Install `argocd` CLI
```shell
brew install argocd
```

Clone the repo
```shell
git clone github.com/csantanapr/gitops-bridge
cd gitops-bridge/argocd/eks/terraform/examples/complete
```

Run terraform
```shell
terraform init
terraform apply
```

Setup kubectl
```shell
$(terraform output -raw configure_kubectl) --kubeconfig /tmp/$(terraform output -raw cluster_name)
export KUBECONFIG=/tmp/$(terraform output -raw cluster_name)
```

Access ArgoCD UI
```shell
export KUBECONFIG=/tmp/$(terraform output -raw cluster_name)
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
kubectl config set-context --current --namespace argocd
argocd admin dashboard
```
Argo CD UI is available at http://localhost:8080


Access Cluster and ArgoCD CLI in a new terminal
```shell
export KUBECONFIG=/tmp/$(terraform output -raw cluster_name)
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd"
kubectl config set-context --current --namespace argocd
kubectl get applications -n argocd
kubectl get applicationsets -n argocd
argocd app list
argocd appset list
```

Destroy
```shell
terraform destroy -target="module.eks_blueprints_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
```