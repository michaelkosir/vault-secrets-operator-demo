resource "helm_release" "vso" {
  depends_on = [kind_cluster.dev, kubernetes_pod.vault]

  name             = "vso"
  namespace        = "vault-secrets-operator"
  create_namespace = true

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  version    = var.vso_version

  set {
    name  = "defaultVaultConnection.enabled"
    value = true
  }

  set {
    name  = "defaultVaultConnection.address"
    value = "http://vault.vault.svc.cluster.local"
  }
}
