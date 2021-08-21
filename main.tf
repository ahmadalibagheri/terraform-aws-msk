module "kafka-cluster" {
  source                 = "./msk-cluster"
  name                   = "Kafka"
  number_of_broker_nodes = 3
  enhanced_monitoring    = "PER_TOPIC_PER_PARTITION"
  environment = "dev"

  broker_node_client_subnets  = ["subnet-a", "subnet-b", "subnet-c"] #Adding your subnet
  broker_node_ebs_volume_size = 20
  broker_node_instance_type   = "kafka.t3.small"
  broker_node_security_groups = ["sg-default"] #Adding your security group

  encryption_in_transit_client_broker = "TLS"
  encryption_in_transit_in_cluster    = true

  configuration_name        = "example-configuration"
  configuration_description = "Example configuration"
  configuration_server_properties = {
    "auto.create.topics.enable" = true
    "delete.topic.enable"       = true
  }

  jmx_exporter_enabled    = true
  node_exporter_enabled   = true
  cloudwatch_logs_enabled = true
  # s3_logs_enabled         = true
  # s3_logs_bucket          = "S3-bucket-msk-log"

}
