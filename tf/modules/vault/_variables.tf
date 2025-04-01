variable "namespace" {
  description = "The namespace in which to deploy Vault."
  type        = string
  default     = "vault"
}

variable "create_namespace" {
  description = "Whether to create the namespace for the Vault server"
  type        = bool
  default     = false
}

variable "name" {
  description = "The kubernetes name for the Vault instance."
  type        = string
  default     = "vault"

}

variable "image" {
  description = "The image to use for the Vault Server."
  type        = string
  default     = "hashicorp/vault:1.19"
}

variable "token" {
  description = "The root token for the dev Vault Server."
  type        = string
  default     = "root"
}

variable "port" {
  description = "The port on which the Vault server will listen."
  type        = number
  default     = 8200

}

variable "node_port" {
  description = "The NodePort for the Vault service."
  type        = number
  default     = 30080
}
