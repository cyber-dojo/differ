# Dead differ-state-reporter lambda

Investigation date: 2026-07-07

## Status (2026-07-07)

Cleanup is planned but NOT yet done. The repo configuration
(`differ/deployment/terraform/environment-reporter/` and
`differ/.github/workflows/tf-environment-reporter.yml`) is present and intact,
deliberately kept in place so the live AWS resources can be removed cleanly with
`terraform destroy` before the files are deleted (see "What needs to be done").
The beta lambda `differ-state-reporter` is still deployed and still firing every
minute, failing every time; nothing has been destroyed. Prod is unverified (no
access).

## Summary

The differ repo carries a nested Terraform stack,
`differ/deployment/terraform/environment-reporter/`, applied by the workflow
`differ/.github/workflows/tf-environment-reporter.yml`. It deploys a lambda
named `differ-state-reporter` (Terraform module `kosli-dev/kosli-reporter/aws`
version `0.5.0`) whose intended job is to report differ's Terraform state file
(`terraform/differ/differ.tfstate`) to a Kosli environment named
`terraform-state-differ-<env>` on a `rate(1 minute)` schedule.

It is dead. In the beta account it is deployed and firing every minute, but
every single invocation crashes at startup and it has never successfully
reported anything to Kosli.

This is distinct from two working reporters:

- The top-level `kosli-environment-reporter/` stack, which reports the running
  app containers of the beta and prod clusters into the `aws-beta` / `aws-prod`
  Kosli environments (live).
- The consolidated `terraform-statefile-paths-reporter` lambda in
  `terraform-base-infra/drift-detection/` (added 2026-06-24), which reports all
  services' state and drift files into `aws-<env>-terraform-drift-detection`
  via `kosli snapshot paths` (live). This is the mechanism that now covers what
  the differ-state-reporter was meant to do, for every service at once.

differ is the only service that still carries this nested per-service reporter.
A grep across all service repos for the `kosli-dev/kosli-reporter/aws` module
targeting a `terraform-state-<service>-<env>` environment returns only differ.

## Beta findings (account 244531986313, eu-central-1)

Confirmed directly against the account (profile `cyberdojo`, AdministratorAccess).

- Lambda `differ-state-reporter`: State `Active`, runtime `provided.al2`, last
  modified 2025-04-07.
- EventBridge rule `differ-state-reporter-cron`: schedule `rate(1 minute)`,
  state `ENABLED`.
- EventBridge rule `differ-state-reporter-s3-configuration-updated`: state
  `ENABLED`.
- Every invocation fails at init with `Runtime.InvalidEntrypoint` (dies in
  ~0.06 ms, ~11 MB used, never reaches the handler). Sample CloudWatch log:

  ```
  REPORT RequestId: fa6a0789-...  Duration: 9.12 ms  Billed Duration: 10 ms  Memory Size: 128 MB  Max Memory Used: 11 MB  Status: error  Error Type: Runtime.InvalidEntrypoint
  INIT_REPORT Init Duration: 0.06 ms  Phase: invoke  Status: error  Error Type: Runtime.InvalidEntrypoint
  ```

- Consequence in Kosli: the target environment `terraform-state-differ-staging`
  does not exist. The Kosli `cyber-dojo` org has only these environments:
  `aws-beta`, `aws-prod`, `aws-beta-terraform-drift-detection`,
  `aws-prod-terraform-drift-detection`, `staging`, `production`. Because the
  lambda has failed on every run (it has been broken since at least its
  2025-04-07 modification), it has never created or reported to
  `terraform-state-differ-staging`.

Net effect: an orphaned lambda invoking roughly 1,440 times per day, failing
every time, for over a year. It produces no useful data and is pure noise
(failed invocations, CloudWatch log volume, minor billed duration).

## What needs to be done to clear the dead reporter

Deleting the repo files alone will NOT stop the running resources, because the
lambda and EventBridge rules already exist in the AWS account. Both the live
AWS resources and the repo configuration need to go.

1. Destroy the live AWS resources in the beta account. Run a `terraform
   destroy` of the `environment-reporter` stack (from
   `differ/deployment/terraform/environment-reporter/`, targeting the beta
   account 244531986313), or, if the Terraform state for that stack is missing
   or awkward, manually delete:
   - lambda function `differ-state-reporter`
   - EventBridge rule `differ-state-reporter-cron` (remove targets first)
   - EventBridge rule `differ-state-reporter-s3-configuration-updated` (remove
     targets first)
   - the lambda's IAM role and the CloudWatch log group
     `/aws/lambda/differ-state-reporter`
   Verify afterwards with `aws lambda get-function --function-name
   differ-state-reporter` returning `ResourceNotFoundException`.

2. Repeat the destroy for the prod account (274425519734). See the prod section
   below - this could not be verified during this investigation.

3. Remove the repo configuration once the resources are gone:
   - delete the directory `differ/deployment/terraform/environment-reporter/`
     (the two `*.tfvars`, `data.tf`, `deployment.tf`, `main.tf`, `variables.tf`,
     `versions.tf`, `tf.sh.env`)
   - delete the workflow `differ/.github/workflows/tf-environment-reporter.yml`

Order matters: destroy the resources first (or at least do not merge the file
deletion expecting it to remove them), then remove the config. If the config is
removed first, the workflow can no longer manage or destroy the stack, leaving
the resources permanently orphaned.

## Prod (account 274425519734, eu-central-1) - NOT VERIFIED

I could not inspect prod to the same depth as beta because of a permissions
wall. The only configured profile for the prod account, `cyberdojo-prod`,
requests the `AdministratorAccess` permission set, and after a successful SSO
login `GetRoleCredentials` still returns `ForbiddenException: No access`. That
error means my SSO identity is not assigned any permission set in the prod
account (beta access works; prod access does not), and re-logging in cannot
change that. No alternative prod role/profile is configured to fall back to.

What is known about prod without account access:

- The Kosli environment `terraform-state-differ-prod` does NOT exist (confirmed
  via the read-only Kosli API), exactly as for beta. So if a prod lambda exists,
  it has likewise never successfully reported.
- The workflow `differ/.github/workflows/tf-environment-reporter.yml` applies
  the stack with a matrix of `[beta, prod]` using identical inputs (only the
  account id and `environment` differ), so prod very likely has the same
  `differ-state-reporter` lambda on the same `rate(1 minute)` cron, in the same
  broken state. This is an inference, not a confirmed observation.

To confirm prod, someone with a permission set in account 274425519734 (or my
identity once granted one) should run:

```
aws lambda get-function --function-name differ-state-reporter --profile cyberdojo-prod --region eu-central-1 \
  --query '{Name:Configuration.FunctionName,State:Configuration.State,LastModified:Configuration.LastModified}'
aws events list-rules --profile cyberdojo-prod --region eu-central-1 \
  --query "Rules[?contains(Name,'differ-state-reporter')].{Name:Name,Schedule:ScheduleExpression,State:State}"
aws logs filter-log-events --log-group-name /aws/lambda/differ-state-reporter \
  --profile cyberdojo-prod --region eu-central-1 --limit 8 --query 'events[].message' --output text
```
