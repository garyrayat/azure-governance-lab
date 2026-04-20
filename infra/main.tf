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
          field  = "[concat('tags[', parameters('tagNames')[0], ']')]"
          exists = "false"
        },
        {
          field  = "[concat('tags[', parameters('tagNames')[1], ']')]"
          exists = "false"
        },
        {
          field  = "[concat('tags[', parameters('tagNames')[2], ']')]"
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

  parameters = jsonencode({
    tagNames = {
      value = ["environment", "owner", "cost_center"]
    }
  })
}

resource "azurerm_policy_definition" "allowed_regions" {
  name         = "allowed_regions_custom"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed regions only"

  metadata = jsonencode({
    category = "General"
  })

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
    }
  })

  policy_rule = jsonencode({
    if = {
      not = {
        field = "location"
        in    = "[parameters('allowedLocations')]"
      }
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "allowed_regions" {
  name                 = "allowed_regions_assignment"
  display_name         = "Allowed Regions Assignment"
  policy_definition_id = azurerm_policy_definition.allowed_regions.id
  subscription_id      = "/subscriptions/${var.subscription_id}"

  parameters = jsonencode({
    allowedLocations = {
      value = ["eastus", "centralus"]
    }
  })
}

# -------------------------------
# PCI INITIATIVE (CORRECT)
# -------------------------------
resource "azurerm_policy_set_definition" "pci_baseline" {
  name         = "pci_baseline"
  policy_type  = "Custom"
  display_name = "PCI Governance Baseline"

  metadata = jsonencode({
    category = "Compliance"
  })

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tags.id

    parameter_values = jsonencode({
      tagNames = {
        value = ["environment", "owner", "cost_center"]
      }
    })
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_regions.id

    parameter_values = jsonencode({
      allowedLocations = {
        value = ["eastus"]
      }
    })
  }
}

resource "azurerm_subscription_policy_assignment" "pci_assignment" {
  name                 = "pci_assignment"
  display_name         = "PCI Governance Assignment"
  policy_definition_id = azurerm_policy_set_definition.pci_baseline.id
  subscription_id      = "/subscriptions/${var.subscription_id}"
}
