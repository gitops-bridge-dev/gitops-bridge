# Multi-Cluster centralized hub-spoke topology

This example deploys ArgoCD on the Hub cluster (ie. management/control-plane cluster).
The spoke clusters are registered as remote clusters in the Hub Cluster's ArgoCD
The ArgoCD on the Hub Cluster deploy addons to the spoke clusters
Each spoke cluster have ArgoCD only use for workloads, not the addons

Each spoke cluster gets deployed an app of apps ArgoCD Application with the name `workloads-${env}`

Deploy the Hub Cluster
```shell
cd hub
terraform init
terraform apply
```

Access Terraform output for Hub Cluster
```shell
cd hub
terraform output
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
