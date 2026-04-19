resource "azurerm_resource_group" "governance_lab" {
  name     = "rg_governance_lab"
  location = var.location

  tags = {
    environment = "dev"
    owner       = "garry"
    cost_center = "platform"
  }
}

resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny_public_ip_custom"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny public IP creation"

  metadata = jsonencode({
    category = "Networking"
  })

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/publicIPAddresses"
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "deny_public_ip" {
  name                 = "deny_public_ip_assignment"
  display_name         = "Deny Public IP Assignment"
  policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  subscription_id      = "/subscriptions/${var.subscription_id}"
}

resource "azurerm_policy_definition" "require_tags" {
  name         = "require_tags_custom"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require tags"

  metadata = jsonencode({
    category = "Tags"
  })

  parameters = jsonencode({
    tagNames = {
      type = "Array"
    }
  })

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          field  = "tags['environment']"
          exists = "false"
        },
        {
          field  = "tags['owner']"
          exists = "false"
        },
        {
          field  = "tags['cost_center']"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "require_tags" {
  name                 = "require_tags_assignment"
  display_name         = "Require Tags Assignment"
  policy_definition_id = azurerm_policy_definition.require_tags.id
  subscription_id      = "/subscriptions/${var.subscription_id}"
}
