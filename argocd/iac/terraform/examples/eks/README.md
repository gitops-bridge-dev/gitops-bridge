# Terraform GitOps Bridge for ArgoCD on Amazon EKS

Install `argocd` CLI
```shell
brew install argocd
```

Clone the repo
```shell
git clone github.com/gitops-bridge-dev/gitops-bridge
```

Select an example
```shell
cd gitops-bridge/argocd/iac/terraform/examples/eks/hello-world
```

Run terraform
```shell
terraform init
terraform apply
```

Setup `kubectl`, by running the command from the `configure_kubectl` output
```shell
terraform output -raw configure_kubectl
```

Setup `argocd`, by running the command from the `configure_argocd` output
```shell
terraform output -raw configure_argocd
```
Argo CD UI is available at http://localhost:8080

Use the `argocd`, Ctrl+C to stop the Argo CD UI
```shell
argocd app list -n argocd
argocd appset list -n argocd
```

Destroy Cluster
```shell
./destroy.sh
```