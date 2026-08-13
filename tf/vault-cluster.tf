resource "kubernetes_namespace_v1" "vault" {
  depends_on = [kind_cluster.dev, kubernetes_service_v1.postgres]

  metadata {
    name = "vault"
  }
}

resource "kubernetes_service_account_v1" "vault" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace_v1.vault.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "vault" {
  metadata {
    name = "vault"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.vault.metadata[0].name
    namespace = kubernetes_namespace_v1.vault.metadata[0].name
  }
}

resource "kubernetes_pod_v1" "vault" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace_v1.vault.metadata[0].name

    labels = {
      app = "vault"
    }
  }

  spec {
    service_account_name = kubernetes_service_account_v1.vault.metadata[0].name

    container {
      name  = "vault"
      image = var.vault_image

      port {
        container_port = var.vault_port
      }

      env {
        name  = "VAULT_DEV_LISTEN_ADDRESS"
        value = "0.0.0.0:${var.vault_port}"
      }

      env {
        name  = "VAULT_DEV_ROOT_TOKEN_ID"
        value = "root"
      }
    }
  }
}

resource "kubernetes_service_v1" "vault" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace_v1.vault.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = kubernetes_pod_v1.vault.metadata[0].name
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = var.vault_port
      node_port   = var.vault_node_port
    }
  }
}
