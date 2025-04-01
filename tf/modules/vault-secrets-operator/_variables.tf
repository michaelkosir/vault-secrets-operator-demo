variable "namespace" {
  description = "The namespace where the Helm chart will be deployed."
  type        = string
  default     = "vault-secrets-operator"
}

variable "name" {
  description = "The name of the Helm release."
  type        = string
  default     = "vso"
}

variable "chart_version" {
  description = "The version of the Helm chart to deploy."
  type        = string
  default     = "0.9.1"
}

variable "vault_address" {
  description = "The address of the Vault server."
  type        = string
}
