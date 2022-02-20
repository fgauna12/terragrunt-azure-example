output vnet_resource_group_name {
  value = var.vnet_resource_group_name
  depends_on = [azurerm_resource_group.vnet_resource_group]
}