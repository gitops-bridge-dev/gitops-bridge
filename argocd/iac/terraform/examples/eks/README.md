# Terraform GitOps Bridge for ArgoCD on Amazon EKS

Examples

Install `argocd` CLI
```shell
brew install argocd
```

Clone the repo
```shell
git clone github.com/gitops-bridge-dev/gitops-bridge
cd gitops-bridge/argocd/iac/terraform/examples/eks/hello-world
```

Run terraform
```shell
terraform init
terraform apply
```

Setup kubectl
```shell
export KUBECONFIG=/tmp/$(terraform output -raw cluster_name)
$(terraform output -raw configure_kubectl)
```

Access ArgoCD UI
```shell
export KUBECONFIG=/tmp/$(terraform output -raw cluster_name)
$(terraform output -raw configure_kubectl)
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
kubectl config set-context --current --namespace argocd
argocd login --port-forward --username admin --password $(argocd admin initial-password | head -1)
argocd admin dashboard --port 8080
```
Argo CD UI is available at http://localhost:8080


Access Cluster and ArgoCD CLI in a new terminal
```shell
export KUBECONFIG=/tmp/$(terraform output -raw cluster_name)
$(terraform output -raw configure_kubectl)
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
kubectl config set-context --current --namespace argocd
argocd login --port-forward --username admin --password $(argocd admin initial-password | head -1)
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