# Multi-Cluster centralized hub-spoke topology (shared responsability)

This example deploys ArgoCD on the Hub cluster (ie. management/control-plane cluster).
The spoke clusters are registered as remote clusters in the Hub Cluster's ArgoCD
The ArgoCD on the Hub Cluster deploy addons to the spoke clusters
Each spoke cluster have ArgoCD only use for workloads, not the addons

Each spoke cluster gets deployed an app of apps ArgoCD Application with the name `workloads-${env}`

This platform team and the application team have a **shared** responsability of the cluster's GitOps configuration with multiple instances of ArgoCD targeting the same cluster,
the platform team responsible of the cluster addons using the ArgoCD instance on the hub cluster and the application team responsible of the workloads using the ArgoCD instance on the spoke cluster.


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
./deploy.sh dev
./deploy.sh staging
./deploy.sh prod
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
./destroy.sh dev
./destroy.sh staging
./destroy.sh prod
```

Destroy Hub Clusters
```shell
cd hub
./destroy.sh
```
