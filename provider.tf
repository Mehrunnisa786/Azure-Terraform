terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "945a5939-f994-4cc8-9fbb-65f8e87eaf5a"
  tenant_id       = "4985148f-6e25-40f9-b903-7bc38d228311"
}