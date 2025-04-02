#
# Auth and Policy
#
resource "vault_auth_backend" "k8s" {
  depends_on = [kubernetes_service.vault]

  type        = "kubernetes"
  path        = "k8s"
  description = "Kubernetes Auth Backend"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  depends_on = [kubernetes_service.vault]

  backend         = vault_auth_backend.k8s.path
  kubernetes_host = "https://kubernetes.default.svc.cluster.local"
}

data "vault_policy_document" "this" {
  rule {
    path         = "kv/data/path/to/secret"
    capabilities = ["read"]
  }

  rule {
    path         = "postgres/creds/${var.workload_role}"
    capabilities = ["read"]
  }
}

resource "vault_policy" "this" {
  depends_on = [kubernetes_service.vault]

  name   = var.workload_role
  policy = data.vault_policy_document.this.hcl
}

resource "vault_kubernetes_auth_backend_role" "this" {
  depends_on = [kubernetes_service.vault]

  backend                          = vault_auth_backend.k8s.path
  role_name                        = var.workload_role
  audience                         = "vault"
  bound_service_account_names      = [var.workload_name]
  bound_service_account_namespaces = [kubernetes_namespace.workload.metadata[0].name]
  token_policies                   = [vault_policy.this.name]
  token_ttl                        = 60 * 60      # 1 hour
  token_max_ttl                    = 60 * 60 * 24 # 1 day
}

#
# KV Secrets
#
resource "vault_mount" "kv" {
  depends_on = [kubernetes_service.vault]

  path        = "kv"
  type        = "kv-v2"
  description = "Key-Value Store"
}

resource "vault_kv_secret_v2" "this" {
  depends_on = [kubernetes_service.vault]

  name  = "path/to/secret"
  mount = vault_mount.kv.path

  data_json = jsonencode({
    hello = "world"
    foo   = "bar"
    ping  = "pong"
    fizz  = "buzz"
    api   = "8D1A95AE-8791-4045-AD3C-77AB480F7EAF"
  })
}

#
# Database Secrets
#
resource "vault_database_secrets_mount" "postgres" {
  depends_on = [kubernetes_service.vault, kubernetes_service.postgres]

  path        = "postgres"
  description = "Database secrets engine for Postgres"

  postgresql {
    name          = "database001"
    allowed_roles = [var.workload_role]

    username       = "postgres"
    password       = var.postgres_password
    connection_url = "postgres://{{username}}:{{password}}@postgres.${kubernetes_namespace.workload.metadata[0].name}.svc.cluster.local/postgres"
  }
}

resource "vault_database_secret_backend_role" "postgres" {
  backend = vault_database_secrets_mount.postgres.path
  name    = var.workload_role
  db_name = vault_database_secrets_mount.postgres.postgresql[0].name

  default_ttl = 60 # 1 minute
  max_ttl     = 60 # 1 minute

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"
  ]
}
