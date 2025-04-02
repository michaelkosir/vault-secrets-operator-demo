#
# Database Secrets
#
resource "vault_database_secrets_mount" "postgres" {
  path        = "postgres"
  description = "Database secrets engine for Postgres"

  postgresql {
    name          = "database001"
    allowed_roles = [local.workload_role]

    username       = var.postgres.username
    password       = var.postgres.password
    connection_url = "postgres://{{username}}:{{password}}@${var.postgres.hostname}/${var.postgres.database}"
  }
}

resource "vault_database_secret_backend_role" "postgres" {
  backend = vault_database_secrets_mount.postgres.path
  name    = local.workload_role
  db_name = vault_database_secrets_mount.postgres.postgresql[0].name

  default_ttl = 60 # 1 minute
  max_ttl     = 60 # 1 minute

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"
  ]
}
