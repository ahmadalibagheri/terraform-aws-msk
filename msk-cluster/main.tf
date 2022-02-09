################################################################################
# Configuration
################################################################################

resource "aws_msk_configuration" "this" {
  count = var.create_msk_configuration ? 1 : 0

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

# ################################################################################
# # MSK Cluster
# ################################################################################

resource "aws_msk_cluster" "this" {
  depends_on = [aws_msk_configuration.this,aws_cloudwatch_log_group,this]

  count = var.create_kafka_cluster ? 1 : 0

  cluster_name           = var.name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    client_subnets  = var.broker_node_client_subnets
    ebs_volume_size = var.broker_node_ebs_volume_size
    instance_type   = var.broker_node_instance_type
    security_groups = var.broker_node_security_groups
  }

  configuration_info {
    arn      = aws_msk_configuration.this[0].arn
    revision = aws_msk_configuration.this[0].latest_revision
  }

  encryption_info {
    encryption_in_transit {
      client_broker = var.encryption_in_transit_client_broker
      in_cluster    = var.encryption_in_transit_in_cluster
    }
    encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.jmx_exporter_enabled
      }
      node_exporter {
        enabled_in_broker = var.node_exporter_enabled
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = var.cloudwatch_logs_enabled
        log_group = var.cloudwatch_logs_enabled ? local.cloudwatch_log_group : null
      }
      firehose {
        enabled         = var.firehose_logs_enabled
        delivery_stream = var.firehose_delivery_stream
      }
      s3 {
        enabled = var.s3_logs_enabled
        bucket  = var.s3_logs_bucket
        prefix  = var.s3_logs_prefix
      }
    }
  }

  timeouts {
    create = lookup(var.timeouts, "create", null)
    update = lookup(var.timeouts, "update", null)
    delete = lookup(var.timeouts, "delete", null)
  }

  # required for appautoscaling
  lifecycle {
    ignore_changes = [broker_node_group_info[0].ebs_volume_size]
  }

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "this" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = coalesce(var.cloudwatch_log_group_name, "/aws/msk/${var.name}")
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}
