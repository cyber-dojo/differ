locals {
  state_key         = "terraform.tfstate"
  environment_id    = "${data.aws_caller_identity.current.id}-${data.aws_region.current.name}"
  state_bucket_name = format("terraform-state-%s", sha1(local.environment_id))
}

module "lambda_reporter" {
  for_each = var.kosli_hosts

  source  = "kosli-dev/kosli-reporter/aws"
  version = "0.5.0"

  name                              = "differ-state-reporter-${each.key}"
  kosli_environment_type            = "s3"
  kosli_host                        = each.value
  kosli_cli_version                 = "v2.7.8"
  kosli_environment_name            = "terraform-state-${var.env}"
  kosli_org                         = "cyber-dojo"
  reported_aws_resource_name        = local.state_bucket_name
  kosli_command_optional_parameters = "--include terraform/differ/main.tfstate"
  schedule_expression               = "rate(5 minutes)"
  tags                              = module.tags.result
}