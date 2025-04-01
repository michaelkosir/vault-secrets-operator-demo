output "internal_address" {
  value = "http://${var.name}.${var.namespace}.svc.cluster.local:${var.port}"
}

output "external_address" {
  value = "http://localhost:${var.node_port}"
}

output "token" {
  value = var.token
}
