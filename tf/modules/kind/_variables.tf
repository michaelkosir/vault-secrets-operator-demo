variable "name" {
  description = "Name of the kind cluster"
  type        = string
  default     = "dev"
}

variable "node_port" {
  description = "Node port for the kind cluster"
  type        = number
  default     = 30080
}

variable "workers" {
  description = "Number of worker nodes in the kind cluster"
  type        = number
  default     = 3
}
