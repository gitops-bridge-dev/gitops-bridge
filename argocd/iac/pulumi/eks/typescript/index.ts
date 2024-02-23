import * as pulumi from "@pulumi/pulumi";
import * as awsx from "@pulumi/awsx";
import * as eks from "@pulumi/eks";
import { createArgoRole } from "./iam"
import { GitOpsClusterConfig } from "./github"

const stackName = pulumi.getStack()
const config = new pulumi.Config()
let roleMappings: eks.RoleMapping[] = []

export const outputs: {[key: string]: any} = {
  "stackName": stackName,
}

// VPC Config
const vpc = new awsx.ec2.Vpc("vpc", {
  cidrBlock: config.require("cidrBlock"),
  numberOfAvailabilityZones: 3,
  enableDnsHostnames: true,
  enableDnsSupport: true,
  subnetSpecs: [
    {
      type: awsx.ec2.SubnetType.Private,
      tags: {
        "karpenter.sh/discovery": `${stackName}-cluster`,
        [`kubernetes.io/cluster/${stackName}-cluster`]: "owned",
        "kubernetes.io/role/internal-elb": "1",
      },
    },
    {
      type: awsx.ec2.SubnetType.Isolated,
      name: "tgw-attachment-subnet",
      cidrMask: 27,
    },
    {
      type: awsx.ec2.SubnetType.Public,
      tags: {
        [`kubernetes.io/cluster/${stackName}-cluster`]: "owned",
        "kubernetes.io/role/elb": "1",
      },
    },
  ],
})

// If we are creating a spoke cluster we need to create argoRole first, ensure it
// gets added to auth mapping for the cluster with the correct permissions
if (config.require("clusterType") === "spoke") {
  const argoRole = createArgoRole(config.require("awsAccountId"), pulumi.output(""), config)
  roleMappings.push({
    roleArn: argoRole.arn,
    username: argoRole.arn,
    groups: ["system:masters"],
  })
  outputs.argoRoleArn = argoRole.arn
}

// Create EKS Cluster with a default node group
const eksCluster = new eks.Cluster(`${stackName}-cluster`, {
  name: `${stackName}-cluster`,
  vpcId: vpc.vpcId,
  version: "1.29",
  publicSubnetIds: vpc.publicSubnetIds,
  privateSubnetIds: vpc.privateSubnetIds,
  roleMappings: roleMappings,
  nodeSecurityGroupTags: {
    "karpenter.sh/discovery": `${stackName}-cluster`
  },
  createOidcProvider: true,
  clusterTags: {
    "karpenter.sh/discovery": `${stackName}-cluster`,
  },
  nodeGroupOptions: {
    nodeSubnetIds: vpc.privateSubnetIds,
    nodeRootVolumeEncrypted: true,
    nodeRootVolumeType: "gp3",
    minSize: 1,
    maxSize: 50,
    desiredCapacity: 10,
  },
})

outputs.clusterName = eksCluster.eksCluster.name
outputs.clusterApiEndpoint = eksCluster.core.endpoint

const oidcProviderUrl = eksCluster.core.oidcProvider?.url as pulumi.Output<string>

// If we are creating the hub cluster we need pods in eks cluster to be able to assume
// so we need cluster created first
if (config.require("clusterType") === "hub") {
  const argoRole = createArgoRole(config.require("awsAccountId"), oidcProviderUrl, config)
  outputs.argoRoleArn = argoRole.arn
}

// Create the GitOps Configuration for the given cluster, one method being to upload
// a file to be added to Github Repo which GitOps Controller could manage or 
// we can create secret object and directly apply that to the cluster
if (config.require("implementationType") === "github") {
  new GitOpsClusterConfig(outputs, config, eksCluster.eksCluster.certificateAuthority.data)
} else if (config.require("implementationType") === "secret") {
  // TODO Implement
}
