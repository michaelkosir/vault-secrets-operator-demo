resource "kubernetes_namespace" "workload" {
  depends_on = [kind_cluster.dev]

  metadata {
    name = var.workload_namespace
  }
}

resource "kubernetes_pod" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.workload.metadata[0].name

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
    namespace = kubernetes_namespace.workload.metadata[0].name
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
