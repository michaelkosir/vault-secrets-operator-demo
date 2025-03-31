resource "kind_cluster" "dev" {
  name           = "dev"
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
        container_port = var.vault_node_port
        host_port      = var.vault_node_port
        protocol       = "TCP"
      }
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }
}
