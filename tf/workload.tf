resource "kubernetes_service_account" "workload" {
  metadata {
    name      = var.workload_name
    namespace = kubernetes_namespace.workload.metadata[0].name
  }
}

resource "kubectl_manifest" "vault_auth" {
  depends_on = [helm_release.vso]

  yaml_body = <<YAML
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultAuth
    metadata:
      name: ${var.workload_role}
      namespace: ${kubernetes_namespace.workload.metadata[0].name}
    spec:
      method: kubernetes
      mount: k8s
      kubernetes:
        role: ${var.workload_role}
        serviceAccount: ${var.workload_name}
        audiences: ["vault"]
    YAML
}

resource "kubectl_manifest" "vault_static_secret" {
  depends_on = [kubectl_manifest.vault_auth]

  yaml_body = <<YAML
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultStaticSecret
    metadata:
      name: static
      namespace: ${kubernetes_namespace.workload.metadata[0].name}
    spec:
      vaultAuthRef: ${var.workload_role}
      mount: kv
      type: kv-v2
      path: path/to/secret
      refreshAfter: 30s
      destination:
        create: true
        name: static
        transformation:
          excludeRaw: true
      rolloutRestartTargets:
        - kind: Deployment
          name: ${var.workload_name}
    YAML
}

resource "kubectl_manifest" "vault_dynamic_secret" {
  depends_on = [kubectl_manifest.vault_auth, vault_database_secret_backend_role.postgres]

  yaml_body = <<YAML
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultDynamicSecret
    metadata:
      name: database
      namespace: ${kubernetes_namespace.workload.metadata[0].name}
    spec:
      vaultAuthRef: ${var.workload_role}
      mount: postgres
      type: database
      path: creds/${var.workload_role}
      destination:
        create: true
        name: database
        transformation:
          excludeRaw: true
      rolloutRestartTargets:
        - kind: Deployment
          name: ${var.workload_name}
    YAML
}

resource "kubernetes_deployment" "workload" {
  depends_on = [kubectl_manifest.vault_static_secret, kubectl_manifest.vault_dynamic_secret]

  metadata {
    name      = var.workload_name
    namespace = kubernetes_namespace.workload.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.workload_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.workload_name
        }
      }

      spec {
        service_account_name = var.workload_name

        container {
          name    = var.workload_name
          image   = "alpine:latest"
          command = ["/bin/sh", "-c"]
          args    = ["env | grep '^[a-z]' && sleep infinity"]

          env_from {
            secret_ref {
              name = "static"
            }
          }

          env_from {
            secret_ref {
              name = "database"
            }
          }
        }
      }
    }
  }
}
