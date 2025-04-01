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
  host                   = kind_cluster.dev.endpoint
  client_key             = kind_cluster.dev.client_key
  cluster_ca_certificate = kind_cluster.dev.cluster_ca_certificate
}

provider "kubectl" {
  config_path            = "~/.kube/config"
  host                   = kind_cluster.dev.endpoint
  client_key             = kind_cluster.dev.client_key
  cluster_ca_certificate = kind_cluster.dev.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    config_path            = "~/.kube/config"
    host                   = kind_cluster.dev.endpoint
    client_key             = kind_cluster.dev.client_key
    cluster_ca_certificate = kind_cluster.dev.cluster_ca_certificate
  }
}

provider "vault" {
  address = "http://localhost:${var.vault_node_port}"
  token   = "root"
}
