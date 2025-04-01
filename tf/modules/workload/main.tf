resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

locals {
  namespace = var.create_namespace ? kubernetes_namespace.this[0].metadata[0].name : var.namespace
}

resource "kubernetes_service_account" "workload" {
  metadata {
    name      = var.name
    namespace = local.namespace
  }
}

resource "kubectl_manifest" "vault_auth" {
  yaml_body = <<YAML
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultAuth
    metadata:
      name: ${var.role}
      namespace: ${local.namespace}
    spec:
      method: kubernetes
      mount: k8s
      kubernetes:
        role: ${var.role}
        serviceAccount: ${var.name}
        audiences: ["vault"]
    YAML
}

resource "kubectl_manifest" "vault_static_secret" {
  yaml_body = <<YAML
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultStaticSecret
    metadata:
      name: static
      namespace: ${kubectl_manifest.vault_auth.namespace}
    spec:
      vaultAuthRef: ${var.role}
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
          name: ${var.name}
    YAML
}

resource "kubectl_manifest" "vault_dynamic_secret" {
  yaml_body = <<YAML
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultDynamicSecret
    metadata:
      name: database
      namespace: ${kubectl_manifest.vault_auth.namespace}
    spec:
      vaultAuthRef: ${var.role}
      mount: postgres
      type: database
      path: creds/${var.role}
      destination:
        create: true
        name: database
        transformation:
          excludeRaw: true
      rolloutRestartTargets:
        - kind: Deployment
          name: ${var.name}
    YAML
}

resource "kubernetes_deployment" "workload" {
  metadata {
    name      = var.name
    namespace = local.namespace

    # annotations to force dependency on VaultStaticSecret and VaultDynamicSecret
    # alternatively use the `depends_on` argument
    annotations = {
      VaultStaticSecret  = "${kubectl_manifest.vault_static_secret.kind}/${kubectl_manifest.vault_static_secret.name}"
      VaultDynamicSecret = "${kubectl_manifest.vault_dynamic_secret.kind}/${kubectl_manifest.vault_dynamic_secret.name}"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        service_account_name = var.name

        container {
          name    = var.name
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
