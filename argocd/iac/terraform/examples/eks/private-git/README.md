# ArgoCD on Amazon EKS

This example shows how to deploy Amazon EKS with addons configured via ArgoCD

The example demonstrate how to use private git repository for addons and workload.

The example reads your private ssh key, and creates two secretes to access the git repository for addons and another one for workloads

## Prerequisites
- Create a Github ssh key file, example assumes the file path `~/.ssh/id_rsa`, update `main.tf` if using a different location

Deploy EKS Cluster
```shell
terraform init
terraform apply
```

Access Terraform output to configure `kubectl` and `argocd`
```shell
terraform output
```

Destroy EKS Cluster
```shell
cd hub
./destroy.sh
```
