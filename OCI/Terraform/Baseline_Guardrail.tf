############################################################
# OCI – BASELINE TENANCY GUARDRAILS (LAYER 1)
#
# Purpose:
# Establish tenancy-level access restrictions that support
# centralized governance and least-privilege administration.
#
# OCI IAM is primarily allow-based. Baseline controls grant
# only the permissions required within approved boundaries.
############################################################


############################################################
# Restrict administrative resource management to
# approved OCI regions
############################################################

resource "oci_identity_policy" "baseline_region_restriction" {
  compartment_id = var.tenancy_ocid
  name           = "baseline-approved-regions"
  description    = "Restrict administrative resource management to approved OCI regions."

  statements = [
    "Allow group Administrators to manage all-resources in tenancy where any {request.region='PHX', request.region='IAD'}"
  ]
}


############################################################
# Allow Object Storage administration without granting
# broad unrestricted tenancy permissions
#
# Public bucket prevention is handled more strongly through
# OCI Security Zones in strict environments.
############################################################

resource "oci_identity_policy" "baseline_object_storage_admin" {
  compartment_id = var.tenancy_ocid
  name           = "baseline-object-storage-admin"
  description    = "Provide controlled Object Storage administration."

  statements = [
    "Allow group ObjectStorageAdmins to manage object-family in tenancy"
  ]
}
