# Argo CD

[Argo CD](https://argo-cd.readthedocs.io/en/stable/) is a declarative, GitOps continuous delivery tool for Kubernetes.

## Usage

Argo CD can be deployed by enabling the add-on via the following.

```hcl
enable_argocd = true
```

You can optionally customize the Helm chart that deploys Argo CD via the following configuration.

```hcl
  enable_argocd = true

  argocd = {
    name          = "argocd"
    chart_version = "5.29.1"
    repository    = "https://argoproj.github.io/argo-helm"
    namespace     = "argocd"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }

```

Verify argocd pods are running.

```sh
$ kubectl get pods -n argocd
NAME                                                        READY   STATUS    RESTARTS   AGE
argo-cd-argocd-application-controller-0                     1/1     Running   0          146m
argo-cd-argocd-applicationset-controller-678d85f77b-rmpcb   1/1     Running   0          146m
argo-cd-argocd-dex-server-7b6c9b5969-zpqnl                  1/1     Running   0          146m
argo-cd-argocd-notifications-controller-6d489b99c9-j6fdw    1/1     Running   0          146m
argo-cd-argocd-redis-59dd95f5b5-8fx74                       1/1     Running   0          146m
argo-cd-argocd-repo-server-7b9bd88c95-mh2fz                 1/1     Running   0          146m
argo-cd-argocd-server-6f9cfdd4d5-8mfpc                      1/1     Running   0          146m
```
