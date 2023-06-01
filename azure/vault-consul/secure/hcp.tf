resource "hcp_hvn" "hvn" {
  hvn_id         = "main-hvn"
  cloud_provider = "azure"
  region         = "westus2"
  cidr_block     = "172.25.16.0/20"
}

resource "hcp_azure_peering_connection" "peer" {
  hvn_link                 = hcp_hvn.hvn.self_link
  peering_id               = "dev"
  peer_vnet_name           = azurerm_virtual_network.test.name
  peer_subscription_id     = data.azurerm_subscription.sub.subscription_id
  peer_tenant_id           = var.peer_tennant_id
  peer_resource_group_name = azurerm_resource_group.main[0].name
  peer_vnet_region         = azurerm_virtual_network.test.location
}

data "hcp_azure_peering_connection" "peer" {
  hvn_link              = hcp_hvn.hvn.self_link
  peering_id            = hcp_azure_peering_connection.peer.peering_id
  wait_for_active_state = true
}

// The route depends on the data source, rather than the resource, to ensure the peering is in an Active state.
resource "hcp_hvn_route" "route" {
  hvn_link         = hcp_hvn.hvn.self_link
  hvn_route_id     = "${random_id.prefix.hex}-route"
  destination_cidr = "172.31.0.0/16"
  #target_link      = data.hcp_azure_peering_connection.peer.self_link
  target_link      = resource.hcp_azure_peering_connection.peer.self_link
}

resource "azuread_service_principal" "principal" {
  application_id = hcp_azure_peering_connection.peer.application_id
}

resource "azurerm_role_definition" "definition" {
  name  = "hcp-hvn-peering-access"
  scope = azurerm_virtual_network.test.id

  assignable_scopes = [
    azurerm_virtual_network.test.id
  ]

  permissions {
    actions = [
      "Microsoft.Network/virtualNetworks/peer/action",
      "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/write"
    ]
  }
}

resource "azurerm_role_assignment" "assignment" {
  principal_id       = azuread_service_principal.principal.id
  scope              = azurerm_virtual_network.test.id
  role_definition_id = azurerm_role_definition.definition.role_definition_resource_id
}