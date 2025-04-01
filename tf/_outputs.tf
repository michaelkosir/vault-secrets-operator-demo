output "vault_addr" {
  value = module.vault.external_address
}

output "vault_token" {
  value = module.vault.token
}
