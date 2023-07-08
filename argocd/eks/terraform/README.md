# Terraform GitOps Bridge for ArgoCD on Amazon EKS

Examples

Install `argocd` CLI
```shell
brew install argocd
```

Clone the repo
```shell
git clone github.com/csantanapr/gitops-bridge
cd gitops-bridge/argocd/eks/terraform/test
```

Run terraform
```shell
terraform init
terraform apply
```

Setup kubectl
```shell
$(terraform output -raw configure_kubectl) --kubeconfig /tmp/gitops
export KUBECONFIG=/tmp/gitops
```

Access ArgoCD UI
```shell
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
kubectl config set-context --current --namespace argocd
argocd app list
argocd appset list
argocd admin dashboard
```
Argo CD UI is available at http://localhost:8080


Access Cluster and ArgoCD CLI in a new terminal
```shell
export KUBECONFIG=/tmp/gitops
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