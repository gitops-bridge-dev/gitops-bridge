# Karpenter and ArgoCD on Fargate

Example on how to deploy Amazon EKS with addons configured via ArgoCD.
- ArgoCD, Karpenter, ALB, CoreDNS run on Fargate
-

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
./destroy.sh
```