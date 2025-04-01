#
# KV Secrets
#
resource "vault_mount" "kv" {
  path        = "kv"
  type        = "kv-v2"
  description = "Key-Value Store"
}

resource "vault_kv_secret_v2" "this" {
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
