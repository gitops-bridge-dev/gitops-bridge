# ArgoCD with ingress domain name

Example on how to deploy Amazon EKS with addons configured via ArgoCD.
In this example the ArgoCD is configured with ingress using a https domain name managed on Route53


**Create DNS Hosted Zone in Route 53:**

In this step you will delegate your registered domain DNS to Amazon Route53. You can either delegate the top level domain or a subdomain.
```shell
export TF_VAR_domain_name=<my-registered-domain> # For example: example.com or subdomain.example.com
```

You can use the Console, or the `aws` cli to create a hosted zone. Execute the following command only once:
```sh
aws route53 create-hosted-zone --name $TF_VAR_domain_name --caller-reference "$(date)"
```
Use the NameServers in the DelegatoinSet to update your registered domain NS records at the registrar.


After creating the Route53 zone deploy the EKS Cluster
```shell
terraform init
terraform apply
```

Access Terraform output to configure `kubectl` and `argocd`
```shell
terraform output
```

To access ArgoCD thru ingress https use the following command to get URL and passwords
```shell
echo "URL: https://$(kubectl get ing -n argocd argo-cd-argocd-server -o jsonpath='{.spec.tls[0].hosts[0]}')"
echo "Username: admin"
echo "Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
```

Destroy EKS Cluster
```shell
cd hub
./destroy.sh
```

