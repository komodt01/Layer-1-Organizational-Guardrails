############################################################
# AZURE – STRICT ORGANIZATIONAL GUARDRAILS (LAYER 1)
#
# Purpose:
# Apply stronger preventive controls for regulated or
# high-security Azure landing-zone environments.
#
# Strict controls reduce workload-team flexibility in favor
# of stronger enterprise security and reduced public exposure.
############################################################


############################################################
# Restrict deployments to approved Azure regions
############################################################

resource "azurerm_policy_definition" "strict_allowed_locations" {
  name                = "strict-allowed-locations"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Strict - Allowed Azure Locations"
  management_group_id = azurerm_management_group.landing_zones.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
        description = "Azure regions approved for strict environments."
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


resource "azurerm_management_group_policy_assignment" "strict_allowed_locations" {
  name                 = "strict-allowed-locations"
  display_name         = "Strict - Allowed Azure Locations"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = azurerm_policy_definition.strict_allowed_locations.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = [
        "eastus",
        "westus2"
      ]
    }
  })

  non_compliance_message {
    content = "Resources in strict environments may only be deployed in approved Azure regions."
  }
}


############################################################
# Require HTTPS for Azure App Service
############################################################

resource "azurerm_policy_definition" "strict_require_app_service_https" {
  name                = "strict-require-app-service-https"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Strict - Require HTTPS for App Service"
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


resource "azurerm_management_group_policy_assignment" "strict_require_app_service_https" {
  name                 = "strict-appsvc-https"
  display_name         = "Strict - Require HTTPS for App Service"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = azurerm_policy_definition.strict_require_app_service_https.id

  non_compliance_message {
    content = "Azure App Service applications must enforce HTTPS."
  }
}


############################################################
# Deny public network access to Azure Storage
############################################################

resource "azurerm_policy_definition" "strict_storage_no_public_access" {
  name                = "strict-storage-no-public-access"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Strict - Disable Public Network Access for Storage"
  management_group_id = azurerm_management_group.landing_zones.id

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          field     = "Microsoft.Storage/storageAccounts/publicNetworkAccess"
          notEquals = "Disabled"
        }
      ]
    }

    then = {
      effect = "deny"
    }
  })
}


resource "azurerm_management_group_policy_assignment" "strict_storage_no_public_access" {
  name                 = "strict-storage-private"
  display_name         = "Strict - Storage Public Network Access Disabled"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = azurerm_policy_definition.strict_storage_no_public_access.id

  non_compliance_message {
    content = "Storage accounts in strict environments must disable public network access."
  }
}


############################################################
# Deny public network access to Azure Key Vault
############################################################

resource "azurerm_policy_definition" "strict_keyvault_no_public_access" {
  name                = "strict-keyvault-no-public-access"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Strict - Disable Public Network Access for Key Vault"
  management_group_id = azurerm_management_group.landing_zones.id

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.KeyVault/vaults"
        },
        {
          field     = "Microsoft.KeyVault/vaults/publicNetworkAccess"
          notEquals = "Disabled"
        }
      ]
    }

    then = {
      effect = "deny"
    }
  })
}


resource "azurerm_management_group_policy_assignment" "strict_keyvault_no_public_access" {
  name                 = "strict-kv-private"
  display_name         = "Strict - Key Vault Public Network Access Disabled"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = azurerm_policy_definition.strict_keyvault_no_public_access.id

  non_compliance_message {
    content = "Key Vaults in strict environments must disable public network access."
  }
}
