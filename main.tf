provider "azurerm" {
  features {}
}

module "azure_vm" {
  source              = "./modules/azure_vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  vm_name             = var.vm_name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_size             = var.vm_size
  environment         = var.environment
}

module "azure_registry_container" {
  source                 = "./modules/azure_registry_container"
  rg_resource_group_name = var.rg_resource_group_name
  acr_name              = var.acr_name   
}
