resource "aws_cloudwatch_log_group" "kafka_logging" {
  name              = "${data.terraform_remote_state.infra.outputs.environment_name}-${var.name}"
  retention_in_days = 30
}

################################################################################
# Configuration
################################################################################

resource "aws_msk_configuration" "kafka_configuration" {
  count = var.create ? 1 : 0

  name              = coalesce(var.configuration_name, var.name)
  description       = var.configuration_description
  kafka_versions    = [var.kafka_version]
  server_properties = join("\n", local.server_properties)
}

locals {
  server_properties = [
    "num.partitions=${lookup(var.kafka_config, "num.partitions", "15")}",
    "default.replication.factor=${lookup(var.kafka_config, "default.replication.factor", "3")}",
    "auto.create.topics.enable=${lookup(var.kafka_config, "auto.create.topics.enable", "true")}",
    "delete.topic.enable=${lookup(var.kafka_config, "delete.topic.enable", "true")}"
  ]
}

################################################################################
# MSK Cluster
################################################################################

resource "aws_msk_cluster" "kafka_cluster" {
  cluster_name           = "${data.terraform_remote_state.infra.outputs.environment_name}-${var.name}"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.instance_count

  broker_node_group_info {
    instance_type   = var.instance_type
    ebs_volume_size = var.kafka_data_disk
    client_subnets  = length(var.subnets) > 0 ? var.subnets : data.terraform_remote_state.infra.outputs.subnet_ids
    security_groups = length(var.security_groups) > 0 ? var.security_groups : [data.terraform_remote_state.infra.outputs.default_sg_id]
  }

  configuration_info {
    arn      = aws_msk_configuration.kafka_configuration.arn
    revision = aws_msk_configuration.kafka_configuration.latest_revision
  }

  encryption_info {
    encryption_in_transit {
      client_broker = var.client_broker_encryption
      in_cluster    = true
    }
  }

  enhanced_monitoring = var.monitoring_type

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.kafka_logging.name
      }
    }
  }

  tags = {
    Name        = "${data.terraform_remote_state.infra.outputs.environment_name}-${var.name}"
    Environment = data.terraform_remote_state.infra.outputs.environment_name
  }
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.create && var.create_cloudwatch_log_group ? 1 : 0

  name              = coalesce(var.cloudwatch_log_group_name, "/aws/msk/${var.name}")
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}

resource "aws_route53_record" "kafka_dns_record" {
  for_each = var.no_dns ? {} : { for v in toset(split(",", replace(aws_msk_cluster.kafka_cluster.bootstrap_brokers, ":9092", ""))) : v => v }
  zone_id  = data.terraform_remote_state.infra.outputs.route53_zone_id
  name     = "${lower(var.name)}-broker${split("-", split(".", each.value)[0])[1]}.${data.terraform_remote_state.infra.outputs.route53_zone_name}"
  type     = "CNAME"
  ttl      = "30"
  records  = [each.value]
}



