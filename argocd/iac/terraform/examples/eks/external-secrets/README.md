# ArgoCD on Amazon EKS

This example shows how to deploy Amazon EKS with addons configured via ArgoCD

The example demonstrate how to use private git repository for workload apps

Create an AWS Secret Manager secret with name `github-ssh-key` and the content in plain text of git private ssh key

Deploy EKS Cluster
```shell
terraform init
terraform apply
```

Access Terraform output to configure `kubectl` and `argocd`
```shell
terraform output
```

After cluster is deploy use the external secret operator to create the ArgoCD secret for git ssh access
```shell
kubectl apply -f secrets/github.yaml
```

Destroy EKS Cluster
```shell
cd hub
./destroy.sh
```
