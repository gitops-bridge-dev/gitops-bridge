import * as pulumi from "@pulumi/pulumi"

export function getValue<T>(output: pulumi.Output<T>) {
  return new Promise<T>((resolve) => {
    output.apply((value) => {
      resolve(value);
    });
  });
}