# Multi-Cluster centralized hub-spoke topology

This example deploys ArgoCD on one cluster (hub management cluster).
The spoke cluster don't have ArgoCD installed, they are register as remote clusters in ArgoCD
Each cluster gets deployed an app of apps ArgoCD Application with the name `workloads-${env}`

Deploy the Hub Cluster
```shell
cd hub
terraform init
terraform apply
```

Deploy the Spoke Clusters
```shell
cd spokes
./deploy dev
./deploy test
./deploy prod
```
Each environment uses a Terraform workspace

Access Terraform output for each environment
```shell
cd spokes
terraform workspace select ${env}
terraform output
```

Destroy Spoke Clusters
```shell
cd spokes
./destroy dev
./destroy test
./destroy prod
```

Destroy Hub Clusters
```shell
cd hub
./destroy.sh
```
