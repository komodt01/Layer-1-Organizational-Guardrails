############################################################
# OCI – STRICT TENANCY GUARDRAILS (LAYER 1)
#
# Purpose:
# Apply stronger preventive controls for regulated or
# high-security OCI compartments.
#
# Strict environments use OCI Security Zones to prevent
# resource configurations that violate defined security
# policies.
#
# Assumptions:
# - Cloud Guard is already enabled in the tenancy.
# - var.strict_compartment_ocid identifies the compartment
#   that should operate under the strict security profile.
# - var.maximum_security_recipe_ocid references OCI's
#   predefined Maximum Security Recipe.
############################################################


############################################################
# Restrict administrative activity to approved OCI regions
#
# OCI IAM uses region keys such as PHX and IAD rather than
# full region identifiers such as us-phoenix-1.
############################################################

resource "oci_identity_policy" "strict_region_restriction" {
  compartment_id = var.tenancy_ocid
  name           = "strict-approved-regions"
  description    = "Restrict administrative resource management to approved OCI regions."

  statements = [
    "Allow group Administrators to manage all-resources in tenancy where any {request.region='PHX', request.region='IAD'}"
  ]
}


############################################################
# Apply OCI Security Zone to strict compartment
#
# Security Zones prevent resource operations that violate
# the security policies contained in the selected recipe.
############################################################

resource "oci_cloud_guard_security_zone" "strict_security_zone" {
  compartment_id         = var.strict_compartment_ocid
  display_name           = "strict-security-zone"
  description            = "Security Zone for regulated or high-security OCI workloads."
  security_zone_recipe_id = var.maximum_security_recipe_ocid
}
