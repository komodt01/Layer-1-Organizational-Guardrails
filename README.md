# Multicloud Organizational Guardrails – Layer 1

This repository demonstrates how enterprise security and governance requirements can be translated into **organization-level preventive guardrails across AWS, Azure, Google Cloud, and Oracle Cloud Infrastructure (OCI)**.

Layer 1 represents the organizational governance boundary of a multicloud environment. The objective is not to make every cloud use identical controls, but to establish consistent **security outcomes** using the native governance mechanisms of each provider.

The Terraform examples are architecture-focused and are not intended to be deployed unchanged into production.

---

## Project Scope

This project focuses specifically on **Layer 1 organizational guardrails**.

It assumes that the organization, management groups, folders, tenancies, compartments, landing zones, networking, and other foundational structures required by the policies already exist.

The project demonstrates how an enterprise could define controls governing:

* Approved deployment locations
* Audit and security-service protection
* Identity and credential restrictions
* Public exposure
* Network configuration
* Organizational governance boundaries
* Higher-security environments requiring stricter controls

The exact implementation differs by cloud because AWS, Azure, GCP, and OCI provide different organizational governance mechanisms.

---

## Baseline vs. Strict Guardrails

Rather than applying the same restrictions to every environment, this project separates controls into two governance profiles.

### Baseline Guardrails

Baseline controls represent security requirements that could reasonably apply across a broad enterprise cloud environment.

Examples include:

* Approved deployment regions or locations
* Protection of audit and configuration monitoring
* HTTPS requirements
* Service-account credential restrictions
* Organizational governance protections
* Prevention of unsafe default configurations

### Strict Guardrails

Strict controls represent additional restrictions appropriate for regulated, sensitive, or high-security workloads.

Examples include:

* Reduced public network exposure
* Private-only workload patterns
* Protection of additional security services
* Prevention of legacy or weaker access mechanisms
* Stronger network and identity restrictions
* OCI Security Zone enforcement

Strict controls intentionally reduce workload-team flexibility in exchange for a stronger security posture.

---

## Cloud Governance Model

A key design principle of this project is that **the security requirement should remain consistent even when the technical enforcement mechanism changes between cloud providers**.

| Cloud | Organizational Governance Mechanism               | Example Guardrails                                                                             |
| ----- | ------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| AWS   | AWS Organizations Service Control Policies (SCPs) | Region restrictions, CloudTrail protection, AWS Config protection, security-service protection |
| Azure | Management Groups + Azure Policy                  | Allowed locations, HTTPS enforcement, public network restrictions                              |
| GCP   | Organization Policy                               | Resource locations, service-account restrictions, external IP restrictions, network controls   |
| OCI   | IAM Policies + Security Zones                     | Regional access boundaries, controlled permissions, Security Zone enforcement                  |

The objective is therefore not service-for-service equivalency. The objective is **equivalent governance outcomes appropriate to each cloud platform**.

---

## Repository Structure

```text
README.md
Security.md
compliance.md

/AWS
    /Terraform
        /baseline
            guardrails.tf
        /strict
            guardrails.tf

/Azure
    /Terraform
        /baseline
            guardrails.tf
        /strict
            guardrails.tf

/GCP
    /Terraform
        /baseline
            guardrails.tf
        /strict
            guardrails.tf

/OCI
    /Terraform
        /baseline
            guardrails.tf
        /strict
            guardrails.tf
```

Baseline and strict configurations are separated because they represent **alternative governance profiles** rather than Terraform files intended to be applied together.

---

## AWS Guardrails

AWS governance is implemented primarily through **AWS Organizations Service Control Policies (SCPs)**.

### Baseline

The baseline profile demonstrates controls for:

* Restricting operations to approved AWS Regions while accounting for required global services
* Preventing CloudTrail from being disabled or deleted
* Protecting AWS Config recording
* Preventing member accounts from leaving centralized organizational governance

### Strict

The strict profile extends the security posture with controls such as:

* Preventing S3 ACL changes
* Protecting GuardDuty
* Protecting Security Hub
* Maintaining the baseline regional and audit protections

A production implementation would also evaluate organization-level S3 Block Public Access policies as part of the enterprise storage governance model.

---

## Azure Guardrails

Azure governance is implemented through **Management Groups and Azure Policy**.

### Baseline

The baseline profile demonstrates:

* Restricting resource deployment to approved Azure locations
* Requiring HTTPS for Azure App Service

### Strict

The strict profile adds stronger exposure controls, including:

* Disabling public network access for Azure Storage
* Disabling public network access for Azure Key Vault
* Maintaining approved-location and HTTPS requirements

Strict public-access controls assume that required private connectivity, Private Endpoints, DNS, and supporting network architecture have already been established.

---

## GCP Guardrails

Google Cloud governance is implemented using **Organization Policy**.

### Baseline

The baseline profile demonstrates:

* Restricting resources to approved locations
* Preventing user-managed service-account key creation
* Preventing automatic IAM grants for default service accounts
* Preventing VM IP forwarding

### Strict

The strict profile adds controls such as:

* Preventing external IP assignment to Compute Engine workloads
* Preventing automatic default VPC creation
* Requiring centralized OS Login
* Maintaining baseline identity and location restrictions

The strict profile assumes private connectivity and controlled ingress/egress patterns are available for workloads that do not receive public IP addresses.

---

## OCI Guardrails

OCI differs from the other providers because organizational governance does not map directly to AWS SCPs, Azure Policy, or GCP Organization Policy.

The architecture therefore uses **OCI IAM policies and Security Zones** to achieve comparable governance outcomes.

### Baseline

The baseline profile demonstrates:

* Region-based administrative restrictions
* Controlled Object Storage administrative permissions
* Tenancy-level least-privilege governance

### Strict

The strict profile adds:

* OCI Security Zone enforcement for high-security compartments
* Stronger preventive controls through an assigned Security Zone recipe
* Continued regional and IAM governance

Cloud Guard and the required Security Zone recipe are assumed to exist before the strict Security Zone configuration is applied.

---

## Architecture Principle

The central design principle behind this project is:

> **Standardize the security outcome, not necessarily the cloud implementation.**

For example, an enterprise may establish a requirement to minimize public workload exposure.

That requirement could be enforced differently across providers:

* AWS through organizational policies and service-specific controls
* Azure through Management Group policy assignments
* GCP through Organization Policy constraints
* OCI through IAM boundaries and Security Zones

The implementation differs, but the governance objective remains consistent.

---

## Relationship to Layer 2

Layer 1 defines **what must be true** across the cloud environment.

Examples include:

* Where resources may be deployed
* Which security controls cannot be disabled
* Whether certain resources may be publicly accessible
* Which identity and network behaviors are permitted

Layer 2 defines **how the cloud environment is constructed to operate within those boundaries**.

Layer 2 includes areas such as:

* Landing-zone architecture
* Core networking
* Shared services
* Identity integration
* Logging and monitoring foundations
* Security services
* Workload deployment scaffolding

Together, Layer 1 and Layer 2 establish a governed cloud foundation:

**Layer 1: policy and boundaries**

**Layer 2: technical foundation and implementation**

---

## Production Considerations

These Terraform examples intentionally focus on architectural patterns rather than a complete production deployment.

A production implementation would additionally require evaluation of:

* Existing organizational hierarchy and inherited policies
* Exceptions and exemption workflows
* Break-glass administration
* Policy deployment and rollback strategy
* Existing-resource remediation
* Policy testing before broad enforcement
* Private connectivity dependencies
* Logging and evidence collection
* Regulatory and data-residency requirements
* Provider-specific service limitations
* Terraform state and deployment controls

Guardrails should be introduced progressively and validated before broad organizational enforcement. A preventive control that is technically correct can still create business disruption if its dependencies and existing workloads are not understood.

---

## What This Repository Demonstrates

This project demonstrates how common enterprise security requirements can be translated into provider-specific organizational controls across AWS, Azure, GCP, and OCI.

It focuses on:

* Multicloud security architecture
* Preventive governance
* Policy-as-code
* Terraform
* Organizational security boundaries
* Baseline vs. high-security control profiles
* Cloud-native governance differences
* Security-by-default architecture
* Governance and compliance alignment

---

## Related Architecture

This repository represents **Layer 1 – Organizational Guardrails** within a broader multicloud governance architecture.

**Layer 0 – Architecture Philosophy & Governance Principles**
Defines the overarching governance model, assumptions, security principles, and multicloud strategy.

**Layer 1 – Organizational Guardrails**
Defines preventive controls and non-negotiable organizational security boundaries.

**Layer 2 – Multicloud Landing Zone**
Provides the networking, identity, logging, shared services, and workload foundation that operates within the Layer 1 boundaries.

The layers intentionally separate **governance intent from platform implementation**, allowing enterprise requirements to remain consistent while individual cloud architectures use the capabilities most appropriate to each provider.
