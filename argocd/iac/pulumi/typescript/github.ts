import * as pulumi from "@pulumi/pulumi";
import * as github from "@pulumi/github";
import * as yaml from 'js-yaml';
import { getValue } from "./utils"
import { env } from "process";

export class GitOpsClusterConfig {
  private config: pulumi.Config;
  private outputs: {[key: string]: pulumi.Output<any>};

  constructor(outputs: {[key: string]: pulumi.Output<any>}, config: pulumi.Config, clusterAuthority: pulumi.Output<string>) {
    this.config = config
    this.outputs = outputs
    const annotations = this.generateAnnotations(pulumi.getStack())
    const serverConfig = this.generateConfig(clusterAuthority)
    getValue(pulumi.all([annotations, serverConfig]).apply(([annotations, serverConfig]) => {
      return {
        apiVersion: "v1",
        kind: "Secret",
        metadata: {
          labels: this.generateLabels(),
          annotations: annotations,
          name: `${pulumi.getStack()}-cluster-secret`,
          namespace: "argocd",
        },
        type: "Opaque",
        stringData: {
          name: pulumi.getStack(),
          server: config.require("clusterType") === "hub" ? "https://kubernetes.default.svc" : `https://${annotations.k8s_service_host}`
        },
        data: {
          config: Buffer.from(serverConfig).toString("base64"),
        },
      }
    })).then(fileContents => {
      const provider = new github.Provider("github", {
        token: env.GITHUB_TOKEN,
        owner: config.require("githubOrg"),
      })
      new github.RepositoryFile("argo-cluster-secret.yaml", {
        repository: config.require("githubRepo"),
        file: config.require("secretPath"),
        content: yaml.dump(fileContents),
        branch: "main",
        commitMessage: `Update Argo Config Secret for ${pulumi.getStack()}`,
        overwriteOnCreate: true,
      }, {provider: provider});
    })
    .catch(err => console.log(err))
  }

  private generateConfig(clusterAuthority: pulumi.Output<string>) {
    if (this.config.require("clusterType") !== "hub") {
      return pulumi.all([this.outputs.argoRoleArn, clusterAuthority]).apply(([argoRoleArn, clusterAuthority]) => `{
  "awsAuthConfig": {
    "clusterName": "${this.config.require("name")}-cluster",
    "roleARN": "${argoRoleArn}"
  },
  "tlsClientConfig": {
    "insecure": false,
    "caData": "${clusterAuthority}"
  }
}
`)
  }
  return `{
  "tlsClientConfig": {
    "insecure": false
  }
}
`
  }

  private generateAnnotations(name: string) {
    // Add More Outputs as needed to output to cluster secret
    const outputs = pulumi.all([
      this.outputs.clusterName,
      this.outputs.clusterApiEndpoint,
    ])
    const annotations = outputs.apply(([
      clusterName,
      clusterApiEndpoint,
    ]) => {
      return {
        "aws_cluster_name": clusterName,
        "k8s_service_host": clusterApiEndpoint.split("://")[1],
      }
    })
    return annotations
  }

  private generateLabels() {
    return {
      "argocd.argoproj.io/secret-type": "cluster",
      ...this.config.requireObject<Object>("clusterComponents"),
    }
  }
}