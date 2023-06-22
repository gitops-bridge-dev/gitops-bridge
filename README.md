# GitOps Bridge

Experiments on working with Infrasctructure as Code (IaC) such as Terraform, CAPI/CAPA, Pulumi, CloudFormation, ACK, CrossPlane, EKSCTL, Kops and GitOps Engine  for Kubernetes in a Mutl-Cluster Environments.

For users that want to use IaC to create a Kuberentes cluster (ie EKS, Kops) and want to use GitOps for anything to be install inside the cluster.

**Terraform**:
- Terraform has providers for helm and kubernetes, the problem with these providers is that terraform is design to have control over the state
of the Kubernetes resources, any changes to these resources outside Terraform for example using `kubectl` or GitOps (ie ArgoCD, Flux) would create problems in terraform state.

