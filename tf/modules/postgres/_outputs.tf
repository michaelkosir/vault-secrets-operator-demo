output "hostname" {
  value = "${var.name}.${var.namespace}.svc.cluster.local:${var.port}"
}

output "username" {
  value = var.username
}

output "password" {
  value = var.password
}

output "database" {
  value = var.database
}
