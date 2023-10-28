# GitOps Bridge

The GitOps Bridge is a community project to show best practices and patterms on how to bridge the process of creating a Kubernetes Cluster to then delegate everything after that to GitOps using [ArgoCD](https://www.cncf.io/projects/argo/) or [FluxCD](https://www.cncf.io/projects/flux/) both CNCF graduated projects.

See the git repository [GitOps Control Plane](https://github.com/gitops-bridge-dev/gitops-bridge-argocd-control-plane-template) for an example template on bootstrapping ArgoCD

There are many tools to create Kubernetes clusters, this include roll your own like kubeadmin/minikube/kind or a cloud managed service like Amazon EKS. It should not matter how the the cluster is created in terms of GitOps, GitOps engines should be compatible with any tool that the user choose to use to create the cluster include cases using Kubernetes to create other Kubernetes clusters like CAPI/CAPA, Crossplane, ACK, or any tool running inside Kubernetes to deploy Kubernetes.

The GitOps Bridge becomes extremely important for cloud managed kubernetes, this cluster have integrations with cloud services. When using GitOps to install a tool in this cases, the tool usually via helm needs to be configure with metadata about resources or workload identity (IAM) that is available as a result of running a IaC tool such terraform, cloudformation, or cloud cli. The GitOps Bridge would show patterns on how to bridge this metadata about the cluster to GitOps using features specific GitOps engine combined.

The GitOps Bridge should also be compatible with GitOps engines that run as Saas and not install inside the cluster such as Akuity Platform, CodeFresh, Weaveworks and others.

### ArgoCD

This git repository contains the files on how to create the Kubernete Clusters and how to bridge the metadata to the GitOps engine, there is an additiona git repository [GitOps Control Plane](https://github.com/gitops-bridge-dev/gitops-bridge-argocd-control-plane-template) that contains the ArgoCD App of Apps to bootstrap and manage the Application Sets for the clusters intended to be use as template to get started.


### Terraform and GitOps Bridge:
- Terraform has providers for helm and kubernetes, the problem with these providers is that terraform is design to have control over the state
of the Kubernetes resources, any changes to these resources outside Terraform for example using `kubectl` or GitOps (ie ArgoCD, FluxCD) would create problems in terraform state.

### ArgoCD Status
| IaC           | GitOps    | Status |
| :---           |    :----: | ---:     |
| Terraform      | ArgoCD    |  Stable [try it!](argocd/iac/terraform/examples/eks/getting-started) |
| EKSCTL         | ArgoCD    |              |
| CDK            | ArgoCD    |              |
| Crossplane     | ArgoCD    |              |
| CAPI           | ArgoCD    |              |
| Pulumi         | ArgoCD    |              |
| ACK            | ArgoCD    |              |
| CloudFormation | ArgoCD    |              |
| Kops           | ArgoCD    |              |
| Ansible        | ArgoCD    |              |

### FluxCD Status
| IaC            | GitOps    | Status |
| :---           |    :----: | ---:     |
| Terraform      | FluxCD    |  Soon |
| EKSCTL         | FluxCD    |              |
| CDK            | FluxCD    |              |
| Crossplane     | FluxCD    |              |
| CAPI           | FluxCD    |              |
| Pulumi         | FluxCD    |              |
| ACK            | FluxCD    |              |
| CloudFormation | FluxCD    |              |
| Kops           | FluxCD    |              |
| Ansible        | FluxCD    |              |

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
