terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.6.0"
    }
    terracurl = {
      source  = "devops-rob/terracurl"
      version = "1.2.2"
    }
  }
}
