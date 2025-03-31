resource "kubernetes_pod" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.workload_namespace

    labels = {
      app = "postgres"
    }
  }

  spec {
    container {
      name  = "postgres"
      image = var.postgres_image

      env {
        name  = "POSTGRES_PASSWORD"
        value = var.postgres_password
      }

      port {
        container_port = var.postgres_port
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.workload_namespace
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = kubernetes_pod.postgres.metadata[0].name
    }

    port {
      port        = var.postgres_port
      target_port = var.postgres_port
    }
  }
}
