resource "helm_release" "vso" {
  depends_on = [kind_cluster.dev, kubernetes_pod_v1.vault]

  name             = "vso"
  namespace        = "vault-secrets-operator"
  create_namespace = true

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  version    = var.vso_version

  set = [
    {
      name  = "defaultVaultConnection.enabled"
      value = true
    },
    {
      name  = "defaultVaultConnection.address"
      value = "http://vault.vault.svc.cluster.local"
    },
  ]
}
