package terraform.azure.network

deny[msg] {
  some rc
  rc := input.resource_changes[_]
  rc.type == "azurerm_public_ip"
  msg := "Public IPs are not allowed"
}
