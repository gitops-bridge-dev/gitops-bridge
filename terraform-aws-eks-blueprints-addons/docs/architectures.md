## Addons

| Addon | x86_64/amd64 | arm64 |
|-------|:------:|:-----:|
| Argo Rollouts | ✅ | ✅ |
| Argo Workflows | ✅ | ✅ |
| Argo CD | ✅ | ✅ |
| AWS CloudWatch Metrics | ✅ | ✅ |
| AWS EFS CSI Driver | ✅ | ✅ |
| AWS for FluentBit | ✅ | ✅ |
| AWS FSx CSI Driver | ✅ | ✅ |
| AWS Load Balancer Controller | ✅ | ✅ |
| AWS Node Termination Handler | ✅ | ✅ |
| AWS Private CA Issuer | ✅ | ✅ |
| Cert Manager | ✅ | ✅ |
| Cluster Autoscaler | ✅ | ✅ |
| Cluster Proportional Autoscaler | ✅ | ✅ |
| External DNS | ✅ | ✅ |
| External Secrets | ✅ | ✅ |
| OPA Gatekeeper | ✅ | ✅ |
| Ingress Nginx | ✅ | ✅ |
| Karpenter | ✅ | ✅ |
| Kube-Prometheus Stack | ✅ | ✅ |
| Metrics Server | ✅ | ✅ |
| Secrets Store CSI Driver | ✅ | ✅ |
| Secrets Store CSI Driver Provider AWS | ✅ | ✅ |
| Velero | ✅ | ✅ |
| Vertical Pod Autoscaler | ✅ | ✅ |

## [Amazon EKS Addons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)

The Amazon EKS provided add-ons listed below support both `x86_64/amd64` and `arm64` architectures. Third party add-ons that are available via the AWS Marketplace will vary based on the support provided by the add-on vendor. No additional changes are required to add-on configurations when switching between `x86_64/amd64` and `arm64` architectures; Amazon EKS add-ons utilize multi-architecture container images to support this functionality. These addons are specified via the `eks_addons` input variable.

| Addon | x86_64/amd64 | arm64 |
|-------|:------:|:-----:|
| AWS VPC CNI | ✅ | ✅ |
| AWS EBS CSI Driver | ✅ | ✅ |
| CoreDNS | ✅ | ✅ |
| Kube-proxy | ✅ | ✅ |
| ADOT Collector | ✅ | ✅ |
| AWS GuardDuty Agent | ✅ | ✅ |
