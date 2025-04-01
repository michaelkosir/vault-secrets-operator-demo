resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account" "vault" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "vault" {
  metadata {
    name = var.name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault.metadata[0].name
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
}

resource "kubernetes_pod" "vault" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.vault.metadata[0].name

    labels = {
      app = var.name
    }
  }

  spec {
    service_account_name = kubernetes_service_account.vault.metadata[0].name

    container {
      name  = var.name
      image = var.image

      port {
        container_port = var.port
      }

      env {
        name  = "VAULT_DEV_LISTEN_ADDRESS"
        value = "0.0.0.0:${var.port}"
      }

      env {
        name  = "VAULT_DEV_ROOT_TOKEN_ID"
        value = var.token
      }
    }
  }
}

resource "kubernetes_service" "vault" {
  metadata {
    name      = kubernetes_pod.vault.metadata[0].name
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = kubernetes_pod.vault.metadata[0].name
    }

    port {
      protocol    = "TCP"
      port        = var.port
      target_port = var.port
      node_port   = var.node_port
    }
  }
}
