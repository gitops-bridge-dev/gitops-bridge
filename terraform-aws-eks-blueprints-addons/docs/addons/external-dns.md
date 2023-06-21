# External DNS

[ExternalDNS](https://github.com/kubernetes-sigs/external-dns) makes Kubernetes resources discoverable via public DNS servers. Like KubeDNS, it retrieves a list of resources (Services, Ingresses, etc.) from the Kubernetes API to determine a desired list of DNS records. Unlike KubeDNS, however, it's not a DNS server itself, but merely configures other DNS providers accordingly—e.g. [AWS Route 53](https://aws.amazon.com/route53/).

## Usage

External DNS can be deployed by enabling the add-on via the following.

```hcl
enable_external_dns = true
```

You can optionally customize the Helm chart that deploys External DNS via the following configuration.

```hcl
  enable_external_dns = true

  external_dns = {
    name          = "external-dns"
    chart_version = "1.12.2"
    repository    = "https://kubernetes-sigs.github.io/external-dns/"
    namespace     = "external-dns"
    values        = [templatefile("${path.module}/values.yaml", {})]
  }
  external_dns_route53_zone_arns = ["XXXXXXXXXXXXXXXXXXXXXXX"]
```

Verify external-dns pods are running.

```sh
$ kubectl get pods -n external-dns
NAME                            READY   STATUS    RESTARTS     AGE
external-dns-849b89c675-ffnf6   1/1     Running   1 (2d ago)   2d5h
```

To further configure external-dns, refer to the examples:

* [AWS Load Balancer Controller](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws-load-balancer-controller.md)
* [Route53](docs/tutorials/aws.md)
    * [Same domain for public and private Route53 zones](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/public-private-route53.md)
* [Cloud Map](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws-sd.md)
* [Kube Ingress AWS Controller](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/kube-ingress-aws.md)
