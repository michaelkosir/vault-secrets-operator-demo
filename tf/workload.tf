resource "kubernetes_namespace" "example" {
  depends_on = [kind_cluster.dev]

  metadata {
    name = "example"
  }
}

resource "kubernetes_service_account" "example" {
  metadata {
    name      = "example"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
}

resource "kubectl_manifest" "vault_auth" {
  depends_on = [helm_release.vso]

  yaml_body = <<YAML
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultAuth
    metadata:
      name: example
      namespace: example
    spec:
      method: kubernetes
      mount: k8s
      kubernetes:
        role: example
        serviceAccount: example
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
      namespace: example
    spec:
      vaultAuthRef: example
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
          name: example
    YAML
}

resource "kubectl_manifest" "vault_dynamic_secret" {
  depends_on = [kubectl_manifest.vault_auth, vault_database_secret_backend_role.postgres]

  yaml_body = <<YAML
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultDynamicSecret
    metadata:
      name: database
      namespace: example
    spec:
      vaultAuthRef: example
      mount: postgres
      type: database
      path: creds/example
      destination:
        create: true
        name: database
        transformation:
          excludeRaw: true
      rolloutRestartTargets:
        - kind: Deployment
          name: example
    YAML
}

resource "kubernetes_deployment" "example" {
  depends_on = [kubectl_manifest.vault_static_secret, kubectl_manifest.vault_dynamic_secret]

  metadata {
    name      = "example"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "example"
      }
    }

    template {
      metadata {
        labels = {
          app = "example"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.example.metadata[0].name

        container {
          name    = "example"
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
