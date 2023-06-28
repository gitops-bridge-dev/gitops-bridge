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
argocd login --username admin --password $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")
argocd app list
argocd appset list
#argocd admin initial-password
argocd admin dashboard
```
Argo CD UI is available at http://localhost:8080


Access ArgoCD CLI in a new terminal
```shell
export KUBECONFIG=/tmp/gitops
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
argocd app list
argocd appset list
```

