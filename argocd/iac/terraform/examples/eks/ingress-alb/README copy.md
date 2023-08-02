# Hello World ArgoCD on Amazon EKS

Example on how to deploy Amazon EKS with addons configured via ArgoCD.
In this example the ArgoCD is use to deploy Crossplane with AWS Providers configured with IRSA

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
