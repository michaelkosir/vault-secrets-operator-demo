module "kind" {
  source = "./modules/kind"

  name    = "dev"
  workers = 3
}

module "postgres" {
  source = "./modules/postgres"

  name             = "postgres"
  namespace        = "demo"
  create_namespace = true
}

module "vault" {
  source = "./modules/vault"

  name             = "vault"
  namespace        = "vault"
  create_namespace = true
  node_port        = module.kind.node_port
}

module "config" {
  source     = "./modules/vault-config"
  depends_on = [module.vault, module.postgres]

  workload_name      = "app01"
  workload_namespace = "demo"
  vault              = module.vault
  postgres           = module.postgres
}

module "vso" {
  source     = "./modules/vault-secrets-operator"
  depends_on = [module.vault]

  name          = "vso"
  namespace     = "vault-secrets-operator"
  chart_version = "0.9.1"
  vault_address = module.vault.internal_address
}

module "workload" {
  source     = "./modules/workload"
  depends_on = [module.postgres, module.vso, module.config]

  name      = "app01"
  namespace = "demo"
  role      = "demo-app01"
}
