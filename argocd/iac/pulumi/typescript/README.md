# Pulumi Typescript GitOps Bridge

### How to Start:

1. Create applicable stack files you need 
2. Update configuration values as you need
3. Add any extra resources you may need in your given environment
4. Update GitOps Config to output any extra values you may need to your GitOps Controller
5. Add an Environment Variable for `GITHUB_TOKEN` in your deployment env (local, Github Actions, AWS Code Pipeline, etc;)
6. `pulumi up`

