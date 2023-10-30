# GitOps Control Plane

Control Plane repository defines the desired state of shared infrastructure components and enables self-service onboarding process for the application developer teams.

This git repository is part of the project [GitOps Bridge](https://github.com/gitops-bridge-dev/gitops-bridge)

Repository contains the following directories:

* **bootstrap/workloads** - This bootstrap uses App of Apps to deploy Application Sets, defines what resources need to be install in all clusters that are not a control plane cluster running ArgoCD.
* **bootstrap/control-plane** - This bootstrap uses App of Apps to deploy Application Sets. Apply this bootstrap into a control plane cluster that is running an management tools like ArgoCD, defines what resource need to be install on this cluster, the cluster by convention needs to be name "in-cluster", this makes it compatible with ArgoCD SaaS like Akuity Platform. If using ArgoCD SaaS do not deploy this bootstrap.
* **charts** - Defines the custom charts
* **environments** - Defines the resources to be deploy per environment type (ie, dev, qa, staging, prod, etc), includes helm values to override the global ones in the chart directory mentioned above
* **clusters** - Defines the resources specific to particular cluster, it overrides the environment
* **teams** - Defines the onboarding of an application across namespaces (dev, test, prod) within the same cluster for developer team.

```
├── bootstrap
│   ├── control-plane
│   │   ├── addons
│   │   │   ├── aws
│   │   │   │   ├── addons-aws-cert-manager-appset.yaml
│   │   │   │   ├── addons-aws-cloudwatch-metrics-appset.yaml
│   │   │   │   ├── addons-aws-cluster-autoscaler-appset.yaml
│   │   │   │   ├── addons-aws-efs-csi-driver-appset.yaml
│   │   │   │   ├── addons-aws-external-dns-appset.yaml
│   │   │   │   ├── addons-aws-external-secrets-appset.yaml
│   │   │   │   ├── addons-aws-for-fluent-bit-appset.yaml
│   │   │   │   ├── addons-aws-fsx-csi-driver-appset.yaml
│   │   │   │   ├── addons-aws-karpenter-appset.yaml
│   │   │   │   ├── addons-aws-load-balancer-controller-appset.yaml
│   │   │   │   ├── addons-aws-node-termination-handler-appset.yaml
│   │   │   │   ├── addons-aws-privateca-issuer-appset.yaml
│   │   │   │   └── addons-aws-velero.yaml
│   │   │   └── oss
│   │   │       ├── addons-argo-rollouts-appset.yaml
│   │   │       └── addons-kyverno-appset.yaml
│   │   ├── clusters
│   │   │   └── clusters-appset.yaml
│   │   └── exclude
│   │       └── bootstrap.yaml
│   └── workloads
│       ├── exclude
│       │   └── bootstrap.yaml
│       └── teams
│           └── teams-appset.yaml
├── charts
│   ├── namespaces
│   └── team
├── clusters
│   ├── cluster-1-dev
│   │   ├── addons
│   ├── cluster-1-prod
│   │   ├── addons
│   ├── cluster-1-qa
│   │   ├── addons
│   ├── cluster-1-staging
│   │   ├── addons
│   └── in-cluster
│       ├── addons
├── environments
│   ├── control-plane
│   │   ├── addons
│   ├── dev
│   │   ├── addons
│   ├── prod
│   │   ├── addons
│   ├── qa
│   │   ├── addons
│   └── staging
│       ├── addons
├── teams
│   └── workloads
│       └── gitops-bridge-dev
│           └── values.yaml


208 directories, 235 files

```
