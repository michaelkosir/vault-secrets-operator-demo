resource "kubernetes_pod" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.example.metadata[0].name

    labels = {
      app = "postgres"
    }
  }

  spec {
    container {
      image = "postgres:17-alpine"
      name  = "postgres"

      env {
        name  = "POSTGRES_PASSWORD"
        value = "root"
      }

      port {
        container_port = 5432
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = kubernetes_pod.postgres.metadata[0].name
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}
