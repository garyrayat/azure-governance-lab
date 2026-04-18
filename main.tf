provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-governance-demo"
  location = "East US"
}
