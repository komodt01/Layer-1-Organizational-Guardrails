############################################################
# GCP – BASELINE ORGANIZATIONAL GUARDRAILS (LAYER 1)
#
# Purpose:
# Establish organization-wide preventive controls that apply
# broadly across Google Cloud projects.
#
# These policies define foundational security requirements
# without unnecessarily restricting normal platform use.
############################################################


############################################################
# Restrict resource deployment to approved locations
############################################################

resource "google_org_policy_policy" "baseline_resource_locations" {
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
# Disable service-account key creation
#
# Long-lived user-managed service-account keys increase
# credential-management risk. Workload identity and other
# short-lived authentication mechanisms are preferred.
############################################################

resource "google_org_policy_policy" "baseline_disable_sa_key_creation" {
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

resource "google_org_policy_policy" "baseline_disable_default_sa_grants" {
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
#
# This reduces the likelihood of unmanaged routing or
# unintended network-transit behavior.
############################################################

resource "google_org_policy_policy" "baseline_disable_ip_forwarding" {
  name   = "organizations/${var.organization_id}/policies/compute.vmCanIpForward"
  parent = "organizations/${var.organization_id}"

  spec {
    rules {
      deny_all = "TRUE"
    }
  }
}
