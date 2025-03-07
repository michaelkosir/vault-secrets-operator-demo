#
# Auth and Policy
#
resource "vault_auth_backend" "k8s" {
  depends_on = [kubernetes_service.vault_external]

  type        = "kubernetes"
  path        = "k8s"
  description = "Kubernetes Auth Backend"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  depends_on = [kubernetes_service.vault_external]

  backend         = vault_auth_backend.k8s.path
  kubernetes_host = "https://kubernetes.default.svc.cluster.local"
}

data "vault_policy_document" "example" {
  rule {
    path         = "kv/data/path/to/secret"
    capabilities = ["read"]
  }

  rule {
    path         = "aws/sts/example"
    capabilities = ["create", "update"]
  }
}

resource "vault_policy" "example" {
  depends_on = [kubernetes_service.vault_external]

  name   = "example"
  policy = data.vault_policy_document.example.hcl
}

resource "vault_kubernetes_auth_backend_role" "example" {
  depends_on = [kubernetes_service.vault_external]

  backend                          = vault_auth_backend.k8s.path
  role_name                        = "example"
  audience                         = "vault"
  bound_service_account_names      = ["example"]
  bound_service_account_namespaces = ["example"]
  token_policies                   = [vault_policy.example.name]
  token_ttl                        = 60 * 60      # 1 hour
  token_max_ttl                    = 60 * 60 * 24 # 1 day
}

#
# KV Secrets
#
resource "vault_mount" "kv" {
  depends_on = [kubernetes_service.vault_external]

  path        = "kv"
  type        = "kv-v2"
  description = "Key-Value Store"
}

resource "vault_kv_secret_v2" "this" {
  depends_on = [kubernetes_service.vault_external]

  name  = "path/to/secret"
  mount = vault_mount.kv.path

  data_json = jsonencode({
    hello = "world"
    foo   = "bar"
  })
}
