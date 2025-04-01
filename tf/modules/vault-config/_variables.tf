#
# Postgres
#
variable "postgres" {
  description = "Map output from Postgres module."
  type        = map(string)
}

#
# Vault
#
variable "vault" {
  description = "Map output from Vault module."
  type        = map(string)
}

#
# Workload
#
variable "workload_name" {
  description = "The name of the workload."
  type        = string
}

variable "workload_namespace" {
  description = "The namespace of the workload."
  type        = string
}

locals {
  workload_role = "${var.workload_namespace}-${var.workload_name}"
}
