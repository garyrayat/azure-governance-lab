package terraform.azure.network

import rego.v1

deny contains msg if {
  some rc in input.resource_changes
  rc.type == "azurerm_public_ip"
  msg := "Public IPs are not allowed"
}
