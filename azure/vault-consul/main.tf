resource "random_id" "prefix" {
  byte_length = 8
}

data "azurerm_subscription" "sub" {
  subscription_id = var.peer_subscription_id
}

resource "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 1 : 0

  location = var.location
  name     = coalesce(var.resource_group_name, "${random_id.prefix.hex}-rg")
}

locals {
  resource_group = {
    name     = var.create_resource_group ? azurerm_resource_group.main[0].name : var.resource_group_name
    location = var.location
  }
}
resource "azurerm_virtual_network" "aks" {
  address_space       = ["10.52.0.0/16"]
  location            = local.resource_group.location
  name                = "${random_id.prefix.hex}-vn"
  resource_group_name = local.resource_group.name
}

resource "azurerm_subnet" "test" {
  address_prefixes     = ["10.52.0.0/24"]
  name                 = "${random_id.prefix.hex}-sn"
  resource_group_name  = local.resource_group.name
  virtual_network_name = azurerm_virtual_network.aks.name
  #enforce_private_link_endpoint_network_policies = true
  private_endpoint_network_policies_enabled = true
}
module "aks" {
  source              = "Azure/aks/azurerm"
  version             = "6.7.1"
  location            = var.location
  prefix              = var.prefix
  rbac_aad            = false
  resource_group_name = local.resource_group.name

}

