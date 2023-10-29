# ArgoCD on Amazon EKS

This example shows how to deploy Amazon EKS with addons configured via ArgoCD

The example demonstrate how to use [External Secret Operator(ESO)](https://external-secrets.io) with
AWS Secret Manager and AWS Systems Manager Parameter Store



## Prerequisites
Before you begin, make sure you have the following command line tools installed:
- git
- terraform
- kubectl
- argocd

## Fork the Git Repositories

### Fork the Addon GitOps Repo
1. Fork the git repository for addons [here](https://github.com/gitops-bridge-dev/gitops-bridge-argocd-control-plane-template).
2. Update the following environment variables to point to your fork by changing the default values:
```shell
export TF_VAR_gitops_addons_org=https://github.com/gitops-bridge-dev
export TF_VAR_gitops_addons_repo=gitops-bridge-argocd-control-plane-template
```

### Fork the Workloads GitOps Repo
1. Fork the git repository for this pattern [here](https://github.com/gitops-bridge-dev/gitops-bridge)
2. Update the following environment variables to point to your fork by changing the default values:
```shell
export TF_VAR_gitops_workload_org=https://github.com/gitops-bridge-dev
export TF_VAR_gitops_workload_repo=gitops-bridge
```

## Deploy the EKS Cluster
Initialize Terraform and deploy the EKS cluster:
```shell
terraform init
terraform apply -auto-approve
```
Retrieve `kubectl` config, then execute the output command:
```shell
terraform output -raw configure_kubectl
```
## Deploy the Addons
Bootstrap the addons using ArgoCD:
```shell
kubectl apply -f bootstrap/addons.yaml
```

### Monitor GitOps Progress for Addons
Wait until all the ArgoCD applications' `HEALTH STATUS` is `Healthy`. Use Crl+C to exit the `watch` command
```shell
watch kubectl get applications -n argocd
```

## Access ArgoCD
Access ArgoCD's UI, run the command from the output:
```shell
terraform output -raw access_argocd
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

## Destroy the EKS Cluster
To tear down all the resources and the EKS cluster, run the following command:
```shell
./destroy.sh
```
