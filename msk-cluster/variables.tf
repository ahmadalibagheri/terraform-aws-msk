variable "infra_data_s3_name" {}
variable "infra_data_s3_region" {}
variable "infra_data_s3_key" {}

variable "name" {}
variable "kafka_version" { default = "2.2.1" }
variable "instance_count" { default = 3 }
variable "instance_type"  {}
variable "kafka_data_disk" { default = "10" }
variable "subnets" { default = [] }
variable "security_groups" { default = [] }
variable "client_broker_encryption" { default = "PLAINTEXT" }
variable "monitoring_type" { default = "PER_BROKER" }
variable "kafka_config" { default = {} }

# Initial creation needs to run with 'no_dns = true'
# as terraform fails to create for_each resources
variable "no_dns" { default = false }

variable "create" {
  description = "Determines whether cluster resources will be created"
  type        = bool
  default     = true
}

################################################################################
# Cluster
################################################################################

variable "name" {
  description = "Name of the MSK cluster"
  type        = string
  default     = "msk" # to avoid: Error: cluster_name must be 1 characters or higher
}

variable "kafka_version" {
  description = "Specify the desired Kafka software version"
  type        = string
  default     = null
}

variable "number_of_broker_nodes" {
  description = "The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets"
  type        = number
  default     = null
}

variable "enhanced_monitoring" {
  description = "Specify the desired enhanced MSK CloudWatch monitoring level. See [Monitoring Amazon MSK with Amazon CloudWatch](https://docs.aws.amazon.com/msk/latest/developerguide/monitoring.html)"
  type        = string
  default     = null
}

variable "broker_node_client_subnets" {
  description = "A list of subnets to connect to in client VPC ([documentation](https://docs.aws.amazon.com/msk/1.0/apireference/clusters.html#clusters-prop-brokernodegroupinfo-clientsubnets))"
  type        = list(string)
  default     = []
}

variable "broker_node_ebs_volume_size" {
  description = "The size in GiB of the EBS volume for the data drive on each broker node"
  type        = number
  default     = null
}

variable "broker_node_instance_type" {
  description = "Specify the instance type to use for the kafka brokers. e.g. kafka.m5.large. ([Pricing info](https://aws.amazon.com/msk/pricing/))"
  type        = string
  default     = null
}

variable "broker_node_security_groups" {
  description = "A list of the security groups to associate with the elastic network interfaces to control who can communicate with the cluster"
  type        = list(string)
  default     = []
}

variable "client_authentication_tls_certificate_authority_arns" {
  description = "List of ACM Certificate Authority Amazon Resource Names (ARNs)"
  type        = list(string)
  default     = []
}

variable "client_authentication_sasl_iam" {
  description = "Enables IAM client authentication"
  type        = bool
  default     = false
}

variable "client_authentication_sasl_scram" {
  description = "Enables SCRAM client authentication via AWS Secrets Manager"
  type        = bool
  default     = false
}

variable "encryption_in_transit_client_broker" {
  description = "Encryption setting for data in transit between clients and brokers. Valid values: `TLS`, `TLS_PLAINTEXT`, and `PLAINTEXT`. Default value is `TLS`"
  type        = string
  default     = null
}

variable "encryption_in_transit_in_cluster" {
  description = "Whether data communication among broker nodes is encrypted. Default value: `true`"
  type        = bool
  default     = null
}

variable "encryption_at_rest_kms_key_arn" {
  description = "You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest. If no key is specified, an AWS managed KMS ('aws/msk' managed service) key will be used for encrypting the data at rest"
  type        = string
  default     = null
}

variable "jmx_exporter_enabled" {
  description = "Indicates whether you want to enable or disable the JMX Exporter"
  type        = bool
  default     = false
}

variable "node_exporter_enabled" {
  description = "Indicates whether you want to enable or disable the Node Exporter"
  type        = bool
  default     = false
}

variable "cloudwatch_logs_enabled" {
  description = "Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs"
  type        = bool
  default     = false
}

variable "firehose_logs_enabled" {
  description = "Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose"
  type        = bool
  default     = false
}

variable "firehose_delivery_stream" {
  description = "Name of the Kinesis Data Firehose delivery stream to deliver logs to"
  type        = string
  default     = null
}

variable "s3_logs_enabled" {
  description = "Indicates whether you want to enable or disable streaming broker logs to S3"
  type        = bool
  default     = false
}

variable "s3_logs_bucket" {
  description = "Name of the S3 bucket to deliver logs to"
  type        = string
  default     = null
}

variable "s3_logs_prefix" {
  description = "Prefix to append to the folder name"
  type        = string
  default     = null
}

variable "timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to the resources created"
  type        = map(string)
  default     = {}
}

################################################################################
# Configuration
################################################################################

variable "configuration_name" {
  description = "Name of the configuration"
  type        = string
  default     = null
}

variable "configuration_description" {
  description = "Description of the configuration"
  type        = string
  default     = null
}

variable "configuration_server_properties" {
  description = "Contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)"
  type        = map(string)
  default     = {}
}
