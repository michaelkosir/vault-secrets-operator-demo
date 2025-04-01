#
# Database Secrets
#
resource "vault_mount" "postgres" {
  path        = "postgres"
  type        = "database"
  description = "Database secrets engine for Postgres"
}

resource "vault_database_secret_backend_connection" "postgres" {
  backend       = vault_mount.postgres.path
  name          = "database001"
  allowed_roles = [local.workload_role]

  postgresql {
    connection_url = "postgres://{{username}}:{{password}}@${var.postgres.hostname}/${var.postgres.database}"
    username       = var.postgres.username
    password       = var.postgres.password
  }
}

resource "vault_database_secret_backend_role" "postgres" {
  backend = vault_mount.postgres.path
  name    = local.workload_role
  db_name = vault_database_secret_backend_connection.postgres.name

  default_ttl = 60 # 1 minute
  max_ttl     = 60 # 1 minute

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';"
  ]
}

# This is a workaround for a potential race condition depending on when `terraform destroy` is run, as there may be active leases
# Terraform works backwards, by first deleting the database connection, and the database mount
# If active leases exist, the engine can't revoke the leases, during mount deletion, as the database connection has already been deleted
resource "terracurl_request" "this" {
  name = "revoke-force"

  url    = "${var.vault.external_address}/v1/sys/health"
  method = "GET"

  response_codes = [
    200
  ]

  destroy_url    = "${var.vault.external_address}/v1/sys/leases/revoke-force/${vault_mount.postgres.path}/creds"
  destroy_method = "PUT"

  destroy_headers = {
    X-Vault-Token = var.vault.token
  }

  destroy_response_codes = [
    204
  ]
}
