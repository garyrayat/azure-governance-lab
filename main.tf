provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-governance-demo"
  location = "East US"
}

resource "azurerm_public_ip" "bad_example" {
  name                = "bad-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.governance_lab.name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "bad_example" {
  name                = "bad-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.governance_lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
