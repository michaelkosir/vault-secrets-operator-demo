# Vault Cluster
variable "vault_image" {
  description = "The specific Vault version to deploy."
  default     = "hashicorp/vault:1.19"
}

variable "vault_port" {
  description = "The port on which Vault will listen."
  default     = 8200
}

variable "vault_node_port" {
  description = "The node port for the Vault service."
  default     = 30080
}

# Vault Secrets Operator
variable "vso_version" {
  description = "The specific Vault Secrets Operator version to deploy."
  default     = "0.9.1"
}

# Postgres
variable "postgres_image" {
  description = "The specific Postgres version to deploy."
  default     = "postgres:17-alpine"
}

variable "postgres_port" {
  description = "The port on which Postgres will listen."
  default     = 5432
}

variable "postgres_password" {
  description = "The value of the Postgres password."
  default     = "root"
}

# Workload
variable "workload_namespace" {
  description = "The namespace in which the workload will be deployed."
  default     = "demo"
}

variable "workload_name" {
  description = "The name of the workload."
  default     = "app01"
}

variable "workload_role" {
  description = "The name of the workload role."
  default     = "demo-app01"
}
