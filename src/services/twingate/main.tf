variable "remote_networks" {
  description = "Twingate remote networks"
  type = map(object({
    connectors = any
    resources  = any
  }))
}

resource "twingate_remote_network" "this" {
  for_each = var.remote_networks

  name = each.key
}

resource "twingate_connector" "this" {
  for_each = merge([
    for network_key, network in var.remote_networks : {
      for connector_key, connector in network.connectors : "${network_key}_${connector_key}" => merge(connector, {
        network_key   = network_key
        connector_key = connector_key
      })
    }
  ]...)

  remote_network_id = twingate_remote_network.this[each.value.network_key].id
}

resource "twingate_connector_tokens" "this" {
  for_each = twingate_connector.this

  connector_id = each.value.id
}

resource "twingate_resource" "this" {
  for_each = merge([
    for network_key, network in var.remote_networks : {
      for resource_key, resource in network.resources : "${network_key}_${resource_key}" => merge(resource, {
        network_key  = network_key
        resource_key = resource_key
      })
    }
  ]...)

  name              = each.value.resource_key
  address           = each.value.address
  remote_network_id = twingate_remote_network.this[each.value.network_key].id

  protocols = each.value.protocols

  lifecycle {
    ignore_changes = [
      access_group
    ]
  }
}

output "connector_tokens" {
  value     = twingate_connector_tokens.this
  sensitive = true
}
