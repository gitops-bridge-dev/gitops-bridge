# Multi-Cluster distributed topology

This example deploys argocd on each cluster, each ArgoCD instance points to the same git repository for cluster addons.
Each cluster gets deployed an app of apps ArgoCD Application with the name `workloads-${env}`

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
./deploy.sh dev
./deploy.sh staging
./deploy.sh prod
```

Each environment uses a Terraform workspace

To access Terraform output run the following commands for the particular environment
```shell
terraform workspace select dev
terraform output
```
```shell
terraform workspace select staging
terraform output
```
```shell
terraform workspace select prod
terraform output
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

### Verify the Addons
Verify that the addons are ready:
```shell
kubectl get deployment -n kube-system \
  metrics-server
```

## Access ArgoCD
Access ArgoCD's UI, run the command from the output:
```shell
terraform output -raw access_argocd
```

### Monitor GitOps Progress for Workloads
Watch until the Workloads ArgoCD Application is `Healthy`
```shell
watch kubectl get -n argocd applications workloads-dev
```
Wait until the ArgoCD Applications `HEALTH STATUS` is `Healthy`. Crl+C to exit the `watch` command

## Destroy the EKS Clusters
To tear down all the resources and the EKS cluster, run the following command:
```shell
./destroy.sh dev
./destroy.sh staging
./destroy.sh prod
```
