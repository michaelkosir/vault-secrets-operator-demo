resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

locals {
  namespace = var.create_namespace ? kubernetes_namespace.this[0].metadata[0].name : var.namespace
}

resource "kubernetes_pod" "postgres" {
  metadata {
    name      = var.name
    namespace = local.namespace

    labels = {
      app = var.name
    }
  }

  spec {
    container {
      name  = var.name
      image = var.image

      env {
        name  = "POSTGRES_USER"
        value = var.username
      }

      env {
        name  = "POSTGRES_PASSWORD"
        value = var.password
      }

      env {
        name  = "POSTGRES_DB"
        value = var.database
      }

      port {
        container_port = var.port
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = var.name
    namespace = local.namespace
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = kubernetes_pod.postgres.metadata[0].name
    }

    port {
      port        = var.port
      target_port = var.port
    }
  }
}
