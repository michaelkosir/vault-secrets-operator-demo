output "vault_addr" {
  value = "http://localhost:${var.vault_node_port}"
}

output "vault_token" {
  value = "root"
}
