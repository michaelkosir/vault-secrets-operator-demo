terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.6.0"
    }
    kind = {
      source  = "tehcyx/kind"
      version = "0.8.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "1.2.2"
    }
  }
}

provider "kubernetes" {
  config_path            = "~/.kube/config"
  host                   = module.kind.endpoint
  client_key             = module.kind.client_key
  cluster_ca_certificate = module.kind.cluster_ca_certificate
}

provider "kubectl" {
  config_path            = "~/.kube/config"
  host                   = module.kind.endpoint
  client_key             = module.kind.client_key
  cluster_ca_certificate = module.kind.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    config_path            = "~/.kube/config"
    host                   = module.kind.endpoint
    client_key             = module.kind.client_key
    cluster_ca_certificate = module.kind.cluster_ca_certificate
  }
}

provider "vault" {
  address = module.vault.external_address
  token   = module.vault.token
}
