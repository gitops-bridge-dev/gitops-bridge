# Terraform and ArgoCD

The idea is to bootstrap a Kubernetes cluster with argocd and anything else to be installed on the cluster is done thru ArgoCD.

ArgoCD has two main patterns to generate ArgoCD Applications
- Apps of Apps, this will allow an Application generate other Applications via helm or kustomize
- Application Sets, this allow to generate ArgoCD Applications definitions dynamically using different Generators

Regardless of Apps of Apps, or Application Sets, ArgoCD should be bootstrat out at least one app with minimal information allowing
all configuration to be stored in Git.

Ideally ArgoCD should be able to manage it self via GitOps



Using a shell script we install argocd, and bootstrap app(s)



#### Researched Resources:
- https://docs.akuity.io/tutorials/adv-gitops
- https://github.com/akuity-adv-gitops-workshop/control-plane-template
- https://github.com/akuity-adv-gitops-workshop/demo-app-template
- https://github.com/akuity-adv-gitops-workshop/demo-app-deploy-template
- https://github.com/rh-mobb/terraform-aro/blob/e2e-gitops/main.tf
- https://github.com/akuity/awesome-argo
- https://github.com/argoproj-labs/argocd-autopilot
- https://www.arthurkoziel.com/setting-up-argocd-with-helm/


