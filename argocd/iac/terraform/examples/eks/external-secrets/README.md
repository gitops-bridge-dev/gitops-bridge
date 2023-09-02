# ArgoCD on Amazon EKS

This example shows how to deploy Amazon EKS with addons configured via ArgoCD

The example demonstrate how to use [External Secret Operator(ESO)](https://external-secrets.io) with
AWS Secret Manager and AWS Systems Manager Parameter Store

Deploy EKS Cluster
```shell
terraform init
terraform apply
```

Access Terraform output to configure `kubectl` and `argocd`
```shell
terraform output
```

Verify that the secrets `external-secrets-ps` and `external-secrets-sm`  are present
```shell
kubectl get secrets -n external-secrets
```

Expected output, should have 3 data items in secret
```
NAME                       TYPE     DATA   AGE
external-secrets-ps        Opaque   2      1m
external-secrets-sm        Opaque   2      1m
```

Destroy EKS Cluster
```shell
cd hub
./destroy.sh
```
