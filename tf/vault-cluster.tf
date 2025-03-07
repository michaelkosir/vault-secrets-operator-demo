resource "kubernetes_namespace" "vault" {
  depends_on = [kind_cluster.dev]

  metadata {
    name = "vault"
  }
}

resource "kubernetes_service_account" "vault" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "vault" {
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
    name      = kubernetes_service_account.vault.metadata[0].name
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
}

resource "kubernetes_pod" "vault" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace.vault.metadata[0].name

    labels = {
      app = "vault"
    }
  }

  spec {
    service_account_name = kubernetes_service_account.vault.metadata[0].name

    container {
      image = "hashicorp/vault:${var.vault_version}"
      name  = "vault"

      port {
        container_port = 8200
      }

      env {
        name  = "VAULT_DEV_LISTEN_ADDRESS"
        value = "0.0.0.0:8200"
      }

      env {
        name  = "VAULT_DEV_ROOT_TOKEN_ID"
        value = "root"
      }
    }
  }
}

resource "kubernetes_service" "vault" {
  metadata {
    name      = "vault"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = kubernetes_pod.vault.metadata[0].name
    }

    port {
      port        = 80
      target_port = 8200
    }
  }
}

resource "kubernetes_service" "vault_external" {
  metadata {
    name      = "vault-external"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  spec {
    type = "NodePort"

    selector = {
      app = kubernetes_pod.vault.metadata[0].name
    }

    port {
      protocol    = "TCP"
      port        = 8200
      target_port = 8200
      node_port   = 30080
    }
  }
}
