resource "azurerm_resource_group" "vnet_resource_group" {
  name     = var.vnet_resource_group_name
  location = var.location
}

