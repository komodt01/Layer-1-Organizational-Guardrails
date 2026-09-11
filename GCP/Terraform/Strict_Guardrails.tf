############################################################
# GCP – STRICT ORGANIZATIONAL GUARDRAILS (LAYER 1)
#
# Purpose:
# Apply stronger preventive controls for regulated or
# high-security Google Cloud environments.
#
# Strict controls reduce direct internet exposure and
# strengthen centralized identity and network governance.
############################################################


############################################################
# Restrict resource deployment to approved locations
############################################################

resource "google_org_policy_policy" "strict_resource_locations" {
  name   = "organizations/${var.organization_id}/policies/gcp.resourceLocations"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      values {
        allowed_values = [
          "in:us-locations"
        ]
      }
    }
  }
}


############################################################
# Disable user-managed service-account key creation
############################################################

resource "google_org_policy_policy" "strict_disable_sa_key_creation" {
  name   = "organizations/${var.organization_id}/policies/iam.disableServiceAccountKeyCreation"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}


############################################################
# Disable automatic IAM grants for default service accounts
############################################################

resource "google_org_policy_policy" "strict_disable_default_sa_grants" {
  name   = "organizations/${var.organization_id}/policies/iam.automaticIamGrantsForDefaultServiceAccounts"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}


############################################################
# Prevent VM instances from enabling IP forwarding
############################################################

resource "google_org_policy_policy" "strict_disable_ip_forwarding" {
  name   = "organizations/${var.organization_id}/policies/compute.vmCanIpForward"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      deny_all = "TRUE"
    }
  }
}


############################################################
# Prevent Compute Engine VMs from receiving external IPs
#
# An empty allow list means no VM is authorized to have an
# external IP unless the policy is deliberately overridden
# at an approved lower scope.
############################################################

resource "google_org_policy_policy" "strict_vm_external_ip_access" {
  name   = "organizations/${var.organization_id}/policies/compute.vmExternalIpAccess"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      values {
        allowed_values = []
      }
    }
  }
}


############################################################
# Prevent automatic creation of default VPC networks
############################################################

resource "google_org_policy_policy" "strict_skip_default_network" {
  name   = "organizations/${var.organization_id}/policies/compute.skipDefaultNetworkCreation"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}


############################################################
# Require centralized OS Login for Compute Engine
############################################################

resource "google_org_policy_policy" "strict_require_os_login" {
  name   = "organizations/${var.organization_id}/policies/compute.managed.requireOsLogin"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}
