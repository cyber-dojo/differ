locals {
  state_key         = "terraform.tfstate"
  environment_id    = "${data.aws_caller_identity.current.id}-${data.aws_region.current.name}"
  state_bucket_name = format("terraform-state-%s", sha1(local.environment_id))
}

module "lambda_reporter" {
  source  = "kosli-dev/kosli-reporter/aws"
  version = "0.5.0"

  name                              = "differ-state-reporter"
  kosli_environment_type            = "s3"
  kosli_host                        = var.KOSLI_HOST
  kosli_cli_version                 = "v2.10.13"
  kosli_environment_name            = "terraform-state-differ-${var.env}"
  kosli_org                         = "cyber-dojo"
  reported_aws_resource_name        = local.state_bucket_name
  kosli_command_optional_parameters = "--include terraform/differ/differ.tfstate"
  schedule_expression               = "rate(1 minute)"
  tags                              = module.tags.result
}