locals {
  cloudwatch_log_group = var.create_msk_configuration && var.create_cloudwatch_log_group ? aws_cloudwatch_log_group.this[0].name : var.cloudwatch_log_group_name
}
