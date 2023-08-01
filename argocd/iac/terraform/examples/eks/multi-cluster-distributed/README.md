# Multi-Cluster distributed topology

This example deploys argocd on each cluster, each ArgoCD instance points to the same git repository for cluster addons.
Each cluster gets deployed an app of apps ArgoCD Application with the name `workloads-${env}`

To deploy run the following commands
```shell
./deploy dev
./deploy test
./deploy prod
```
Each environment uses a Terraform workspace

To access Terraform output run the following commands for the particular environment
```shell
terraform workspace select ${env}
terraform output
```

To destroy run the following commands
```shell
./destroy dev
./destroy test
./destroy prod
```
