# AWS Secret Manager for ArgoCD Admin Password

Example on how to deploy Amazon EKS with addons configured via ArgoCD.
In this example the ArgoCD admin secret is stored in AWS Secret Manager

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

### Monitor GitOps Progress for Addons
Wait until all the ArgoCD applications' `HEALTH STATUS` is `Healthy`. Use Crl+C to exit the `watch` command
```shell
watch kubectl get applications -n argocd
```

## Get the ArgoCD password from AWS Secret Manager
To get the argocd `admin` password stored in AWS Secret Manager
```shell
aws secretsmanager get-secret-value --secret-id argocd --output json | jq -r .SecretString
```

## Access ArgoCD
Access ArgoCD's UI, run the command from the output:
```shell
terraform output -raw access_argocd
```

Destroy EKS Cluster
```shell
cd hub
./destroy.sh
```
