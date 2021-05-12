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
