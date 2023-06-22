# GitOps Bridge

Experiments on working with Infrasctructure as Code (IaC) such as Terraform, CAPI/CAPA, Pulumi, CloudFormation, ACK, CrossPlane, EKSCTL, Kops and GitOps Engine  for Kubernetes in a Mutl-Cluster Environments.

For users that want to use IaC to create a Kuberentes cluster (ie EKS, Kops) and want to use GitOps for anything to be install inside the cluster.

**Terraform**:
- Terraform has providers for helm and kubernetes, the problem with these providers is that terraform is design to have control over the state
of the Kubernetes resources, any changes to these resources outside Terraform for example using `kubectl` or GitOps (ie ArgoCD, Flux) would create problems in terraform state.

#### Researched Resources:
- https://docs.akuity.io/tutorials/adv-gitops
- https://github.com/akuity-adv-gitops-workshop/control-plane-template
- https://github.com/akuity-adv-gitops-workshop/demo-app-template
- https://github.com/akuity-adv-gitops-workshop/demo-app-deploy-template
- https://github.com/akuity/awesome-argo
- https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd
- https://github.com/argoproj-labs/argocd-autopilot
- https://github.com/rh-mobb/terraform-aro/blob/e2e-gitops/main.tf
- https://www.arthurkoziel.com/setting-up-argocd-with-helm/
- https://github.com/hivenetes/k8s-bootstrapper