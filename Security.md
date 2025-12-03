# Security Considerations

This layer focuses on cloud-wide governance. It applies controls at the organizational, management-group, tenancy, or folder scope instead of individual workloads.

---

## 1. Scope of Layer 1

In scope:
- Cloud-wide policies and restrictions
- Organizational/folder/management group hierarchy
- Restricting unsafe deployments
- Region, service, and network enforcement

Out of scope:
- Networking and runtime infrastructure (Layer 2)
- Workloads and application resources (Layer 3)

---

## 2. Identity and Access Management

Layer 1 assumes privileged access is:
- Federated through an identity provider
- MFA protected
- Least-privilege assigned

No access keys or static secrets are included.

---

## 3. Policy Enforcement

Examples by cloud:
- AWS SCPs restrict service usage globally
- Azure Policy enforced at management group
- GCP Org Policies restrict resource locations & defaults
- OCI tenancy policy restricts admin and read access

These guardrails prevent misconfiguration or drift at scale.

---

## 4. Security Principles Applied

- Segmentation at the organizational scope
- Policy-as-code for governance
- IAM separation of duties by design
- No direct modification of cloud configuration by users without guardrail evaluation

---

## 5. Security Expectations

This layer enables:
- Strong isolation by default
- Region/service restrictions
- Mandatory compliance baselines
- Centralized cloud governance

Additional controls (logging, IAM lifecycle, federation) belong in enterprise identity and Layer 2.
