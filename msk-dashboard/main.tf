data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.infra_data_s3_name
    key    = var.infra_data_s3_key
    region = var.infra_data_s3_region
  }
}

resource "kubernetes_service" "kafka-ui" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = var.host_name
    namespace = var.namespace
    labels = {
      app = "${var.host_name}"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app = "${var.host_name}"
    }

    type = "NodePort"
  }
}


resource "kubernetes_deployment" "kafka-ui" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = var.host_name
    namespace = var.namespace
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "${var.host_name}"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.host_name}"
        }
      }

      spec {
        container {
          name  = var.host_name
          image = "${data.terraform_remote_state.infra.outputs.owner_id}.dkr.ecr.${data.terraform_remote_state.infra.outputs.aws_region}.amazonaws.com/kafkauiimage:${var.kafka_ui_image}"

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          env {
            name  = "KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS"
            value = var.kafka_bootstap
          }

          env {
            name  = "KAFKA_CLUSTERS_0_NAME"
            value = "local"
          }

        }
        node_selector = {
          "kubernetes.io/role" = "node"
        }
      }
    }
  }
}

resource "kubernetes_ingress" "kafka-ui_internal" {
  count = var.public_ingress ? 1 : 0
  metadata {
    name      = var.host_name
    namespace = var.namespace
    annotations = {
      "alb.ingress.kubernetes.io/group.name" = "default"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}]"

      "alb.ingress.kubernetes.io/scheme" = "internal"

      "alb.ingress.kubernetes.io/security-groups" = "${var.security_groups}"

      "alb.ingress.kubernetes.io/tags" = "${var.host_name}"

      "kubernetes.io/ingress.class" = "alb"
    }
  }
  spec {
    rule {
      host = "${var.host_name}.${data.terraform_remote_state.infra.outputs.route53_zone_name}"

      http {
        path {
          backend {
            service_name = var.host_name
            service_port = "8080"
          }
        }
      }
    }
  }
}