############################################################
# AZURE – BASELINE ORGANIZATIONAL GUARDRAILS (LAYER 1)
#
# Purpose:
# Establish broad preventive controls at the Azure
# management-group level for landing-zone subscriptions.
#
# These controls are intended to be broadly applicable
# enterprise defaults rather than workload-specific rules.
############################################################


############################################################
# Allow deployments only in approved Azure regions
############################################################

resource "azurerm_policy_definition" "allowed_locations" {
  name                = "baseline-allowed-locations"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Baseline - Allowed Azure Locations"
  management_group_id = azurerm_management_group.landing_zones.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
        description = "Azure regions approved for resource deployment."
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "location"
          notIn = "[parameters('listOfAllowedLocations')]"
        },
        {
          field     = "location"
          notEquals = "global"
        }
      ]
    }

    then = {
      effect = "deny"
    }
  })
}


resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "baseline-allowed-locations"
  display_name         = "Baseline - Allowed Azure Locations"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = azurerm_policy_definition.allowed_locations.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [
        "eastus",
        "westus2"
      ]
    }
  })

  non_compliance_message {
    content = "Resource deployment is restricted to approved Azure regions."
  }
}


############################################################
# Require HTTPS for Azure App Service
############################################################

resource "azurerm_policy_definition" "require_app_service_https" {
  name                = "baseline-require-app-service-https"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Baseline - Require HTTPS for App Service"
  management_group_id = azurerm_management_group.landing_zones.id

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Web/sites"
        },
        {
          field     = "Microsoft.Web/sites/httpsOnly"
          notEquals = true
        }
      ]
    }

    then = {
      effect = "deny"
    }
  })
}


resource "azurerm_management_group_policy_assignment" "require_app_service_https" {
  name                 = "baseline-appsvc-https"
  display_name         = "Baseline - Require HTTPS for App Service"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = azurerm_policy_definition.require_app_service_https.id

  non_compliance_message {
    content = "Azure App Service applications must enforce HTTPS."
  }
}
