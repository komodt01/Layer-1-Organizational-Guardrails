############################################################
# GCP – STRICT ORGANIZATIONAL GUARDRAILS (LAYER 1)
############################################################

# Deny external IPs on VM instances
resource "google_organization_policy" "deny_external_ip" {
  org_id     = var.organization_id
  constraint = "constraints/compute.vmExternalIpAccess"

  list_policy {
    deny = true
  }
}

# Restrict allowed GCP services
resource "google_organization_policy" "restrict_services" {
  org_id     = var.organization_id
  constraint = "constraints/serviceuser.services"

  list_policy {
    allowed_values = [
      "compute.googleapis.com",
      "storage.googleapis.com"
    ]
  }
}
