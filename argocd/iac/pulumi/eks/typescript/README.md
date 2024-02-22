# Pulumi Typescript GitOps Bridge

### How to Start Your Hub Cluster:

1. Create applicable stack files you need - The `Pulumi.dev.yaml` and `Pulumi.hub.yaml` each correspond to one stack for your hub cluster and one stack for a development environment spoke cluster
2. Create a GitOps Repo - Add a README.md and stub out the files you will be adding the ArgoCD Cluster secrets to. 
3. Update configuration values as you need - You will want to update Stack Files with configuration for Github Repo/Org, as well as AWS Account ID, CIDRs, etc;
4. Add any extra resources you may need in your given environment
5. Add an Environment Variable for `GITHUB_TOKEN` in your deployment env (local, Github Actions, AWS Code Pipeline, etc;)
6. `pulumi up --stack hub`
7. Wait for the Resources to create like VPC, EKS Cluster, and IAM permissions
8. Run `./bootstrap.sh`


### How to Add Spoke Clusters:

1. Add any extra resources you may need in your given environment
2. Add an Environment Variable for `GITHUB_TOKEN` in your deployment env (local, Github Actions, AWS Code Pipeline, etc;)
3. Run Pulumi Up for the Spoke Cluster's Stack `pulumi up --stack dev`
4. Wait for the Resources to create like VPC, EKS Cluster, and IAM permissions
5. Apply the Secret resource that was added to the GitOps Repository

### Productionizing your Implementation

* Add Authentication for ArgoCD to be able to grab from your Organization's private repository
* Add ApplicationSets to your configuration by looking at the GitOps Bridge Control Plane Template for resources you need
* Create an ArgoCD Application that manages deployment of your Cluster Secret
* Move your EKS Cluster to be a private access endpoint