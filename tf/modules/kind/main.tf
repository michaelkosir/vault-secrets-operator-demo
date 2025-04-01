resource "kind_cluster" "this" {
  name           = var.name
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      api_server_port = 6443
    }

    node {
      role = "control-plane"

      extra_port_mappings {
        container_port = var.node_port
        host_port      = var.node_port
        protocol       = "TCP"
      }
    }

    dynamic "node" {
      for_each = range(var.workers)
      content {
        role = "worker"
      }
    }
  }
}
