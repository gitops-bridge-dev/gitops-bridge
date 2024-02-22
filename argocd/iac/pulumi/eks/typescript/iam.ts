import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

export function createArgoRole(
  awsAccountId: string, 
  oidcProviderUrl: pulumi.Output<any>, 
  config: pulumi.Config,
  ) {
  if (config.require("clusterType") === "spoke") {
    const hubStack = new pulumi.StackReference("hub-argorole-ref", {
      name: config.require("hubStackName")
    })
    const outputs = hubStack.getOutput("outputs") as pulumi.Output<{[key: string]: string}>
    const policy = outputs.apply((outputs) => JSON.stringify({
      Version: "2012-10-17",
      Statement: [
        {
          Effect: "Allow",
          Principal: {
            AWS: outputs.argoRoleArn
          },
          Action: "sts:AssumeRole"
        }
      ]
    }))
    return new aws.iam.Role("argo-role", {
      assumeRolePolicy: policy
    })
  }
  return new aws.iam.Role("argo-role", {
    inlinePolicies: [
      {
        name: "Argo",
        policy: JSON.stringify({
          Version: "2012-10-17",
          Statement: [
            {
              Sid: "ArgoSecrets",
              Action: [
                "secretsmanager:List*",
                "secretsmanager:Read*"
              ],
              Resource: "*",
              Effect: "Allow",
            },
            {
              Sid: "AssumeRoles",
              Action: [
                "sts:AssumeRole"
              ],
              Resource: "*",
              Effect: "Allow"
            },
          ],
        })
      }
    ],
    assumeRolePolicy: oidcProviderUrl.apply(v => JSON.stringify({
      Version: "2012-10-17",
      Statement: [
        {
          Effect: "Allow",
          Principal: {
            Federated: `arn:aws:iam::${awsAccountId}:oidc-provider/${v}`
          },
          Action: "sts:AssumeRoleWithWebIdentity",
          Condition: {
            StringLike: {
              [`${v}:sub`]: ["system:serviceaccount:argocd:argocd-application-controller", "system:serviceaccount:argocd:argocd-server"],
              [`${v}:aud`]: "sts.amazonaws.com"
            }
          }
        }
      ]
    }))
  })
}