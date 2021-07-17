variable "infra_data_s3_name"   {}
variable "infra_data_s3_region" {}
variable "infra_data_s3_key"    {}
variable "enabled"              { default = true }
variable "host_name"            { default = "kafka-ui" }
variable "eks_name"             {}
variable "security_groups"      {}
variable "kafka_bootstap"       {}
variable "replicas"             { default = "1" }
variable "public_ingress"       { default = true }
variable "namespace"            { default = "default" }
variable "kafka_ui_image"       { default = "0.2.1-20211215114334" }
