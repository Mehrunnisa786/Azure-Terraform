terraform {
  backend "azurerm" {
    resource_group_name  = "demo-resource"
    storage_account_name = "trainwithafrah"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}