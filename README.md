# Terraform GitOps Bridge

Differents experiments on working with Terraform for Cloud Infrasctructure and GitOps for Kubernetes in a Mutl-Cluster Environments.

For users that want to use Terraform to create a Kuberentes cluster (ie EKS) want to use GitOps for anything to be install inside the cluster.

Terraform has provider for helm and kubernetes, the problem with these providers is that terraform is design to have control over the state
of the Kubernetes resources, any changes to these resources outside Terraform for example using `kubectl` or GitOps (ie ArgoCD, Flux)

