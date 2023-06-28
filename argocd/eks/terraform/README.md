# Terraform GitOps Bridge for ArgoCD on Amazon EKS

Examples


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

Setup kubectl for the new cluster
```shell
$(terraform output -raw configure_kubectl --kubeconfig /tmp/gitops)
export KUBECONFIG=/tmp/gitop
```

Access ArgoCD from CLI and UI
```shell
kubectl config set-context --current --namespace argocd
export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
argocd login --username admin --password $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")
argocd app list
argocd appset list
argocd admin initial-password
argocd admin dashboard
```