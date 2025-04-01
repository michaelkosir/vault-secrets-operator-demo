variable "namespace" {
  description = "The kubernetes namespace to deploy the PostgreSQL instance"
  type        = string
  default     = "default"
}

variable "create_namespace" {
  description = "Whether to create the namespace for the PostgreSQL instance"
  type        = bool
  default     = false
}

variable "name" {
  description = "The kubernetes name for the PostgreSQL instance"
  type        = string
  default     = "postgres"
}

variable "port" {
  description = "The port on which PostgreSQL will be exposed"
  type        = number
  default     = 5432
}

variable "image" {
  description = "The Docker image for PostgreSQL"
  type        = string
  default     = "postgres:17-alpine"
}

variable "username" {
  description = "The username for PostgreSQL"
  type        = string
  default     = "postgres"
}

variable "password" {
  description = "The password for PostgreSQL"
  type        = string
  default     = "root"
}

variable "database" {
  description = "The name of the PostgreSQL database"
  type        = string
  default     = "postgres"
}
