# Argo Rollouts

[Argo Rollouts](https://argo-rollouts.readthedocs.io/en/stable/) is a Kubernetes controller and set of CRDs which provide advanced deployment capabilities such as blue-green, canary, canary analysis, experimentation, and progressive delivery features to Kubernetes.

## Usage

Argo Rollouts can be deployed by enabling the add-on via the following.

```hcl
enable_argo_rollouts = true
```

You can optionally customize the Helm chart that deploys Argo Rollouts via the following configuration.

```hcl
  enable_argo_rollouts = true

  argo_rollouts = {
    name          = "argo-rollouts"
    chart_version = "2.22.3"
    repository    = "https://argoproj.github.io/argo-helm"
    namespace     = "argo-rollouts"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }

```

Verify argo-rollouts pods are running.

```sh
$ kubectl get pods -n argo-rollouts
NAME                             READY   STATUS    RESTARTS   AGE
argo-rollouts-5db5688849-x89zb   0/1     Running   0          11s
```
