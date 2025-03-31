resource "helm_release" "vso" {
  depends_on = [kind_cluster.dev, kubernetes_pod.vault]

  name             = "vso"
  namespace        = "vault-secrets-operator"
  create_namespace = true

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  version    = var.vso_version
}

resource "kubectl_manifest" "vault_connection" {
  depends_on = [helm_release.vso]

  yaml_body = <<YAML
    apiVersion: secrets.hashicorp.com/v1beta1
    kind: VaultConnection
    metadata:
      name: default
      namespace: vault-secrets-operator
    spec:
      address: http://vault.vault.svc.cluster.local
    YAML
}
