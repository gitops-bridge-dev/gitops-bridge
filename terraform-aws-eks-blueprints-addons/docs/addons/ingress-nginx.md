# Ingress Nginx

This add-on installs [Ingress Nginx Controller](https://kubernetes.github.io/ingress-nginx/deploy/) on Amazon EKS. The Ingress Nginx controller uses [Nginx](https://www.nginx.org/) as a reverse proxy and load balancer.

Other than handling Kubernetes ingress objects, this ingress controller can facilitate multi-tenancy and segregation of workload ingresses based on host name (host-based routing) and/or URL Path (path based routing).

## Usage

Ingress Nginx Controller can be deployed by enabling the add-on via the following.

```hcl
enable_ingress_nginx = true
```

You can optionally customize the Helm chart that deploys `ingress-nginx` via the following configuration.

```hcl
  enable_ingress_nginx = true

  ingress_nginx = {
    name          = "ingress-nginx"
    chart_version = "4.6.1"
    repository    = "https://kubernetes.github.io/ingress-nginx"
    namespace     = "ingress-nginx"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }

```

Verify ingress-nginx pods are running.

```sh
$ kubectl get pods -n ingress-nginx
NAME                                       READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-f6c55fdc8-8bt2z   1/1     Running   0          44m
```
