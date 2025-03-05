terraform {
  backend "azurerm" {
    resource_group_name  = "ConfigResources"
    storage_account_name = "jamesterraformstate"
    container_name       = "terraformdbvmstate"
    key                  = "azure-db-function.tfstate"
  }
}