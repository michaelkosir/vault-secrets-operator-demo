resource "helm_release" "vso" {
  name             = var.name
  namespace        = var.namespace
  create_namespace = true

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  version    = var.chart_version

  set {
    name  = "defaultVaultConnection.enabled"
    value = true
  }

  set {
    name  = "defaultVaultConnection.address"
    value = var.vault_address
  }
}
