```hcl
############################################################
# OCI – BASELINE TENANCY GUARDRAILS (LAYER 1)
#
# Purpose:
# Demonstrate tenancy-level IAM patterns that support
# centralized governance and least-privilege administration.
#
# OCI IAM is primarily allow-based. These examples define
# scoped permission grants but do not create deny boundaries
# equivalent to AWS Organizations SCPs.
############################################################


############################################################
# Region-conditioned administrative grant
#
# This policy allows the Administrators group to manage
# resources when requests occur in the approved OCI regions.
#
# IMPORTANT:
# OCI IAM policies are additive. This statement does not
# independently prevent access in other regions if broader
# permissions are granted to the same principals elsewhere.
############################################################

resource "oci_identity_policy" "baseline_region_restriction" {
  compartment_id = var.tenancy_ocid
  name           = "baseline-approved-regions"
  description    = "Provide an administrative resource-management grant conditioned on approved OCI regions."

  statements = [
    "Allow group Administrators to manage all-resources in tenancy where any {request.region='PHX', request.region='IAD'}"
  ]
}


############################################################
# Controlled Object Storage administration
#
# Grants ObjectStorageAdmins permission to manage the
# object-family without granting general all-resources
# administration through this policy.
#
# Effective permissions must still be evaluated across all
# applicable OCI IAM policies.
#
# Public bucket prevention is handled more strongly through
# OCI Security Zones in strict environments.
############################################################

resource "oci_identity_policy" "baseline_object_storage_admin" {
  compartment_id = var.tenancy_ocid
  name           = "baseline-object-storage-admin"
  description    = "Provide Object Storage administration through a dedicated IAM group."

  statements = [
    "Allow group ObjectStorageAdmins to manage object-family in tenancy"
  ]
}
```
