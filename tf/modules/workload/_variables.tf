variable "namespace" {
  description = "The namespace to deploy the sample workload"
  type        = string
  default     = "default"
}

variable "create_namespace" {
  description = "Whether to create the namespace for the Workload"
  type        = bool
  default     = false
}

variable "name" {
  description = "The name of the sample workload"
  type        = string
  default     = "app01"
}

variable "role" {
  description = "The name of the workload role"
  type        = string
}
