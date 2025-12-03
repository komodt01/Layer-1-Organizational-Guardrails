############################################################
# AZURE – STRICT ORGANIZATIONAL GUARDRAILS (LAYER 1)
############################################################

# Allowed VM SKUs
resource "azurerm_policy_definition" "allowed_vm_skus" {
  name         = "allowed-vm-skus"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Allowed VM SKUs"

  parameters = {
    listOfAllowedSKUs = {
      type = "Array"
    }
  }

  policy_rule = jsonencode({
    if = {
      field = "Microsoft.Compute/virtualMachines/sku.name"
      notIn = "[parameters('listOfAllowedSKUs')]"
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_policy_assignment" "assign_allowed_vm_skus" {
  scope                = azurerm_management_group.landing_zones.id
  policy_definition_id = azurerm_policy_definition.allowed_vm_skus.id

  parameters = {
    listOfAllowedSKUs = {
      value = [
        "Standard_B2s",
        "Standard_DS2_v2"
      ]
    }
  }
}

# Enforce HTTPS for App Services
resource "azurerm_policy_definition" "enforce_https" {
  name         = "enforce-https"
  policy_type  = "Custom"
  display_name = "App Services must enforce HTTPS"

  policy_rule = <<POLICY
{
  "if": {
    "allOf": [
      { "field": "type", "equals": "Microsoft.Web/sites" },
      { "field": "Microsoft.Web/sites/httpsOnly", "notEquals": "true" }
    ]
  },
  "then": { "effect": "deny" }
}
POLICY
}
