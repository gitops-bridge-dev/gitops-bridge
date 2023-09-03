# Hello World ArgoCD on Amazon EKS

Example on how to deploy Amazon EKS with addons configured via ArgoCD.
In this example the ArgoCD admin secret is stored in AWS Secret Manager

Deploy EKS Cluster
```shell
terraform init
terraform apply
```

Access Terraform output to configure `kubectl` and `argocd` (it includes argocd password)
```shell
terraform output
```

To get the argocd `admin` password stored in AWS Secret Manager
```shell
aws secretsmanager get-secret-value --secret-id argocd --output json | jq -r .SecretString
```

Destroy EKS Cluster
```shell
cd hub
./destroy.sh
```
