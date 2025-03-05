resource "azurerm_resource_group" "rg" {
  name     = var.rg_resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.rg_resource_group_name
  location            = var.location
  sku                 = var.container_sku
  admin_enabled       = var.admin_enabled
}