# Multicloud Organizational Guardrails – Layer 1

## Overview

This project demonstrates a **Layer 1 organizational guardrail architecture** across AWS, Azure, Google Cloud, and Oracle Cloud Infrastructure.

The objective is not to make every cloud use identical technical controls.

The objective is to establish consistent **enterprise security outcomes** using the governance mechanisms native to each provider.

The architecture focuses on controls that sit above individual workloads and influence what subordinate accounts, subscriptions, projects, and compartments are permitted to do.

> **Standardize the security outcome, not necessarily the cloud implementation.**

---

## Architectural Purpose

Enterprise multicloud environments rarely have one governance mechanism that works identically everywhere.

AWS uses Organizations and Service Control Policies.

Azure uses Management Groups and Azure Policy.

Google Cloud uses Organization Policy.

OCI combines IAM policy with controls such as Security Zones.

Layer 1 translates enterprise security requirements into these provider-native mechanisms while preserving a common governance intent.

Examples include:

* Restricting resource deployment locations
* Protecting audit and security capabilities
* Reducing persistent credential use
* Limiting public exposure
* Preventing workloads from escaping organizational governance
* Applying stronger restrictions to higher-risk environments

The Terraform in this repository is **architecture-focused**. It demonstrates representative guardrail patterns and is not intended to be deployed unchanged into a production organization.

---

## Layer 1 in the Architecture

This repository represents the organizational governance layer.

```text
Enterprise Security Requirements
              |
              v
     Layer 1 Guardrails
              |
              v
 Provider-Native Governance
              |
              v
 Organizational Hierarchy
              |
              v
     Workload Environments
```

Layer 1 determines what must be true across governed environments.

It does not build the complete workload platform.

Landing zones, network topology, private connectivity, DNS, workload identity, application architecture, and similar implementation capabilities belong primarily to Layer 2 and downstream architecture.

This distinction matters because some Layer 1 restrictions are only operationally viable when the supporting Layer 2 architecture already exists.

---

## Baseline and Strict Governance Profiles

The project uses two governance profiles rather than applying maximum restriction everywhere.

### Baseline

Baseline guardrails represent controls intended to apply broadly across enterprise environments.

They establish foundational security requirements while preserving reasonable workload flexibility.

### Strict

Strict guardrails apply stronger restrictions for regulated, sensitive, or higher-risk environments.

These controls reduce workload flexibility in exchange for a narrower permitted operating space.

Strict is not automatically better.

A stronger preventive control can create operational failure if its architectural dependencies are not ready.

For example, disabling public access before private connectivity and DNS are available may secure the public boundary while simultaneously making a legitimate workload unusable.

---

# AWS Guardrails

AWS Layer 1 governance is modeled with **AWS Organizations Service Control Policies (SCPs)**.

SCPs constrain the maximum permissions available to principals in governed member accounts. They do not grant permissions themselves.

## Baseline

The baseline examples define SCPs for:

* Approved AWS Regions
* CloudTrail protection
* AWS Config protection
* Prevention of member accounts leaving the AWS Organization

The approved-region policy accounts for selected global AWS services that may require access outside normal regional restrictions.

## Strict

The strict profile includes the baseline security intent and adds controls for:

* S3 ACL modification
* GuardDuty detector deletion
* Security Hub disablement

The S3 ACL restriction should not be interpreted as complete prevention of public S3 exposure.

Production architecture should evaluate controls such as organization-level S3 Block Public Access and other provider-native protections as part of the broader data-security posture.

## AWS Enforcement Boundary

The Terraform in this repository defines the SCPs.

It does **not** attach those policies to an AWS Organization root, Organizational Unit, or account.

Production enforcement therefore requires deliberate policy attachment to the appropriate organizational scope.

A defined SCP is not equivalent to an enforced SCP.

---

# Azure Guardrails

Azure Layer 1 governance is modeled through **Management Groups and Azure Policy**.

Unlike the AWS examples in this repository, the Azure Terraform includes both policy definitions and management-group policy assignments.

## Baseline

The baseline profile includes:

* Approved Azure locations
* HTTPS enforcement for Azure App Service

## Strict

The strict profile adds:

* Disabled public network access for Azure Storage
* Disabled public network access for Azure Key Vault

These restrictions assume that workloads have viable private connectivity.

Production environments would typically require supporting capabilities such as:

* Private Endpoints
* Private DNS
* Routing
* Controlled administrative access
* Monitoring and operational recovery paths

The policy can enforce the restriction, but Layer 2 must provide the architecture that allows the workload to operate within it.

---

# Google Cloud Guardrails

Google Cloud Layer 1 governance is modeled with **Organization Policy**.

The policies in this repository target the organization scope through the supplied organization identifier.

## Baseline

The baseline profile includes:

* Approved resource locations
* Disabled user-managed service-account key creation
* Disabled automatic IAM grants for default service accounts
* Prevention of VM IP forwarding

These controls support centralized identity and network governance while reducing reliance on persistent credentials.

## Strict

The strict profile adds:

* Prevention of external IP addresses on Compute Engine VMs
* Prevention of automatic default VPC creation
* Required OS Login

These controls assume that alternative connectivity and administrative paths have been designed.

Organization Policy should also be evaluated against existing resources because preventive policy does not necessarily remediate configurations that already exist.

---

# OCI Guardrails

OCI requires a different governance interpretation than AWS, Azure, or Google Cloud.

OCI IAM is primarily **allow-based**.

A narrowly scoped IAM statement does not independently create the same type of hard permission boundary as an AWS SCP if broader permissions are granted elsewhere.

Effective permissions must therefore be evaluated across the applicable OCI IAM policy set.

## Baseline

The baseline examples demonstrate:

* A region-conditioned administrative IAM grant
* Dedicated Object Storage administration through a separate IAM group

The administrative policy conditions that specific grant on approved OCI regions.

It should not be interpreted as independently preventing administrative access in other regions when another applicable policy grants broader permissions.

## Strict

The strict profile combines:

* A region-conditioned administrative IAM grant
* OCI Security Zone enforcement for a designated strict compartment

Security Zones provide stronger preventive enforcement by rejecting resource operations that violate the selected Security Zone recipe.

The example assumes that Cloud Guard is already enabled and that the required strict compartment and Maximum Security Recipe identifiers are available.

---

## Governance Authority and Inheritance

Organizational guardrails are fundamentally about **authority**.

The important architecture path is:

```text
Enterprise Requirement
        |
        v
Governance Authority
        |
        v
Provider-Native Control
        |
        v
Assignment / Scope
        |
        v
Inheritance
        |
        v
Workload Enforcement
```

A Terraform resource existing in a repository is not proof that a workload is governed.

The architecture must distinguish between a control that is:

* Defined
* Deployed
* Assigned or attached
* Inherited
* Enforced
* Tested
* Monitored

The provider mechanisms differ, but this distinction applies across the multicloud environment.

See [`trust-boundaries.md`](trust-boundaries.md) for the governance authority and trust-boundary model.

---

## Exception Governance

Enterprise guardrails need a controlled way to handle legitimate deviations.

The preferred response to a workload conflict is not to weaken a centralized policy for every environment.

A production exception process should consider:

* Business justification
* Affected workload
* Requested deviation
* Risk
* Compensating controls
* Approval authority
* Scope
* Monitoring requirements
* Review or expiration date

This repository describes the architectural requirement for exception governance but does not implement a formal exception-management platform.

---

## Validation and Evidence

Governance should be validated as an enforcement chain rather than only as Terraform configuration.

```text
Requirement
    |
    v
Policy Definition
    |
    v
Assignment / Attachment
    |
    v
Inheritance
    |
    v
Enforcement Test
    |
    v
Evidence
```

Production evidence may include policy assignments, SCP attachments, organizational hierarchy records, denied deployment events, compliance results, policy-change logs, Terraform execution records, and approved exceptions.

This distinction supports traceability between security intent and actual cloud enforcement.

---

## Production Considerations

A production implementation should evaluate additional requirements including:

* Organizational hierarchy and inheritance
* Separation of duties
* Privileged governance administration
* Policy deployment authorization
* Break-glass access
* Exception lifecycle management
* Rollout and rollback strategy
* Existing-resource remediation
* Private-connectivity dependencies
* Terraform state protection
* Policy testing
* Monitoring and evidence retention
* Data residency requirements
* Provider-specific limitations

These considerations are intentionally broader than the representative Terraform examples contained in this repository.

---

## Repository Structure

```text
Layer-1-Organizational-Guardrails/
│
├── AWS/
│   └── Terraform/
│       ├── Baseline_Guardrails.tf
│       └── Strict_Guardrails.tf
│
├── Azure/
│   └── Terraform/
│       ├── Baseline_Guardrails.tf
│       └── Strict_Guardrails.tf
│
├── GCP/
│   └── Terraform/
│       ├── Baseline_Guardrails.tf
│       └── Strict_Guardrails.tf
│
├── OCI/
│   └── Terraform/
│       ├── Baseline_Guardrail.tf
│       └── Strict_Guardrails.tf
│
├── README.md
├── Security.md
├── TECHNICAL_CASE_STUDY.md
├── compliance.md
└── trust-boundaries.md
```

---

## Supporting Documentation

### Security Model

[`Security.md`](Security.md) describes the security principles, control boundaries, exceptions, validation model, and production considerations behind the guardrails.

### Governance and Trust Boundaries

[`trust-boundaries.md`](trust-boundaries.md) focuses on governance authority, organizational inheritance, workload administration, privileged governance changes, exception paths, and evidence.

### Technical Case Study

[`TECHNICAL_CASE_STUDY.md`](TECHNICAL_CASE_STUDY.md) explains the architectural decisions, provider differences, failure paths, tradeoffs, and lessons learned from translating common enterprise security outcomes across four cloud providers.

### Compliance Alignment

[`compliance.md`](compliance.md) maps the architecture to relevant security and governance objectives without treating the repository as evidence of certification or attestation.

---

## Architecture Principle

A multicloud security architecture should not force every provider into the same technical model.

It should define the required enterprise security outcome, understand the governance capabilities of each cloud, place enforcement at the appropriate organizational boundary, and preserve enough evidence to demonstrate that the intended control actually reaches the workload.

**Standardize the security requirement. Use the provider-native mechanism. Verify the enforcement boundary.**
