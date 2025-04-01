resource "vault_auth_backend" "k8s" {
  type        = "kubernetes"
  path        = "k8s"
  description = "Kubernetes Auth Backend"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend         = vault_auth_backend.k8s.path
  kubernetes_host = "https://kubernetes.default.svc.cluster.local"
}

data "vault_policy_document" "this" {
  rule {
    path         = "kv/data/path/to/secret"
    capabilities = ["read"]
  }

  rule {
    path         = "postgres/creds/${local.workload_role}"
    capabilities = ["read"]
  }
}

resource "vault_policy" "this" {
  name   = local.workload_role
  policy = data.vault_policy_document.this.hcl
}

resource "vault_kubernetes_auth_backend_role" "this" {
  backend   = vault_auth_backend.k8s.path
  role_name = local.workload_role
  audience  = "vault"

  bound_service_account_names      = [var.workload_name]
  bound_service_account_namespaces = [var.workload_namespace]

  token_policies = [vault_policy.this.name]
  token_ttl      = 60 * 60      # 1 hour
  token_max_ttl  = 60 * 60 * 24 # 1 day
}
