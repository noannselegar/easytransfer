# Easy Transfer Project

## Infra

All the infrastructure is managed by CloudFormation, managing different components in separate stacks.

**TO-DO**
  - Create a GitHub Actions Workflow for automating deployment / updating of CFN Stacks.
  - - nice to have: Changeset summary behind an approval gate.

## App Source

The frontend is managed under **webapp** folder. Lambda functions will act as the backend, under **lambdas/$name**.

