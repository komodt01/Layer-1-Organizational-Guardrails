# Security Architecture

## Purpose

This document describes the security model for the **Multicloud Organizational Guardrails – Layer 1** project.

Layer 1 establishes preventive governance controls at the highest practical organizational boundary across AWS, Azure, Google Cloud, and Oracle Cloud Infrastructure (OCI).

The objective is to establish consistent enterprise security outcomes while using the governance capabilities native to each cloud provider.

These examples demonstrate architecture patterns and are not intended to be deployed unchanged into production.

---

## Security Model

The Layer 1 security model is based on several principles:

* Establish security boundaries before workload deployment
* Apply preventive controls at organizational scope where appropriate
* Protect audit and security capabilities from being disabled
* Reduce unnecessary public exposure
* Prefer short-lived or centrally governed identities over persistent credentials
* Separate broadly applicable baseline controls from stricter controls
* Allow provider-native implementation differences
* Design exceptions deliberately rather than weakening organization-wide controls

The goal is not to make AWS, Azure, GCP, and OCI technically identical.

The goal is to make required **security outcomes consistent**.

---

## Baseline and Strict Security Profiles

Two security profiles are used throughout the project.

### Baseline

Baseline guardrails represent controls that could reasonably apply across a broad enterprise cloud environment.

They establish minimum expectations for areas such as:

* Approved deployment locations
* Audit and configuration protection
* Secure transport
* Identity and credential management
* Network configuration
* Organizational governance

Baseline controls are intended to improve security posture without unnecessarily preventing normal enterprise workloads.

### Strict

Strict guardrails are intended for regulated, sensitive, or high-security environments.

They add controls that may reduce workload flexibility, including:

* Stronger restrictions on public network exposure
* Private workload patterns
* Additional protection of security services
* Stronger identity controls
* Prevention of weaker or legacy access mechanisms
* Security-zone enforcement

Strict controls should only be assigned after required dependencies such as private connectivity, DNS, identity integration, and centralized security services are available.

---

# AWS Security Controls

AWS organizational governance is implemented primarily through **AWS Organizations Service Control Policies (SCPs)**.

SCPs establish permission boundaries for member accounts. They do not grant permissions.

## Baseline Controls

The AWS baseline profile includes:

* Approved-region restrictions
* CloudTrail protection
* AWS Config protection
* Prevention of member accounts leaving centralized organizational governance

The region restriction accounts for AWS services that operate through global endpoints so that an organizational region policy does not unintentionally disrupt required global services.

## Strict Controls

The strict profile adds protections including:

* Prevention of S3 ACL changes
* GuardDuty protection
* Security Hub protection

The strict profile is intended for environments where security teams require stronger protection against workload administrators weakening centralized security capabilities.

### S3 Public Access

S3 public exposure should not be controlled solely by attempting to detect public ACL values through an SCP.

A production architecture should evaluate organization-level **S3 Block Public Access** enforcement and other appropriate S3 governance controls.

The project therefore separates the security requirement — preventing unintended public storage — from a potentially incomplete SCP implementation.

---

# Azure Security Controls

Azure organizational governance is implemented using **Management Groups and Azure Policy**.

Policy definitions describe the required configuration, while assignments apply those requirements to the appropriate management-group scope.

## Baseline Controls

The Azure baseline profile includes:

* Approved Azure locations
* HTTPS enforcement for Azure App Service

These controls establish geographic deployment boundaries and prevent App Service applications from operating without encrypted HTTPS transport.

## Strict Controls

The strict profile adds:

* Public network access disabled for Azure Storage
* Public network access disabled for Azure Key Vault

These restrictions assume that the supporting private connectivity architecture has already been established.

For example, disabling public access without Private Endpoints, DNS resolution, routing, and administrative access patterns could make a resource inaccessible.

The security control therefore has a dependency on the Layer 2 network architecture.

---

# GCP Security Controls

Google Cloud governance is implemented using **Organization Policy**.

Organization Policy allows constraints to be applied above individual projects so that workload teams inherit enterprise security requirements.

## Baseline Controls

The GCP baseline profile includes:

* Approved resource locations
* Prevention of user-managed service-account key creation
* Prevention of automatic IAM grants for default service accounts
* Prevention of VM IP forwarding

These controls reduce persistent credential risk, overly permissive default identities, unmanaged network-transit behavior, and unapproved resource placement.

## Strict Controls

The strict profile adds:

* Prevention of external IP assignment to Compute Engine workloads
* Prevention of default VPC network creation
* Centralized OS Login requirements

The strict environment assumes private connectivity and controlled ingress and egress paths are available.

Existing resources must also be evaluated before enforcement because organizational policy changes do not necessarily remediate every previously deployed resource automatically.

---

# OCI Security Controls

OCI uses a different governance model from AWS, Azure, and GCP.

The project therefore uses a combination of **OCI IAM policies and Security Zones** rather than attempting to reproduce another provider's policy model.

## Baseline Controls

The OCI baseline profile demonstrates:

* Region-conditioned administrative permissions
* Controlled Object Storage permissions
* Tenancy-level least-privilege governance

OCI IAM permissions must be evaluated together because broader permissions granted elsewhere may affect the resulting authorization posture.

## Strict Controls

The strict profile uses **OCI Security Zones** for high-security compartments.

Security Zones provide preventive enforcement against configurations that violate the assigned security recipe.

This is particularly useful for environments requiring stronger restrictions around resource exposure and configuration.

Cloud Guard and the required Security Zone recipe are assumed to exist before the strict profile is applied.

---

# Security Control Layers

Layer 1 is not intended to provide every cloud security control.

It establishes organizational boundaries that other architecture layers build upon.

### Layer 1 — Organizational Guardrails

Controls what cloud teams are permitted to deploy or change.

Examples:

* Region restrictions
* Identity restrictions
* Public exposure restrictions
* Security-service protection

### Layer 2 — Landing Zone

Provides the infrastructure required to operate inside those boundaries.

Examples:

* Network topology
* Private connectivity
* DNS
* Shared services
* Identity integration
* Central logging

### Workload Security

Provides controls specific to individual applications and workloads.

Examples:

* Application authorization
* Secrets management
* Workload identity
* WAF configuration
* Vulnerability management
* Container security

Layer 1 therefore provides the **outer governance boundary**, not the entire security architecture.

---

# Exceptions

Enterprise guardrails require an exception model.

A legitimate workload may occasionally require behavior prohibited by the standard policy.

Examples could include:

* A workload requiring deployment in another region
* An internet-facing service requiring approved public connectivity
* A legacy integration requiring a temporary credential exception
* A security or networking appliance requiring capabilities normally prohibited for application workloads

An exception should not result in simply weakening the enterprise-wide guardrail.

A production exception process should identify:

* Business justification
* Resource or workload scope
* Risk
* Compensating controls
* Approver
* Expiration or review date
* Required monitoring

Where possible, exceptions should be applied at the narrowest appropriate organizational scope.

---

# Failure and Operational Considerations

Preventive guardrails can create operational impact if they are introduced without understanding existing workloads and dependencies.

Examples include:

* Region restrictions blocking an existing service dependency
* Public-access restrictions breaking applications before private connectivity exists
* Identity restrictions breaking automation dependent on long-lived credentials
* Security-service protection interfering with an approved administrative workflow
* Organizational policy changes affecting deployment pipelines

For this reason, production guardrails should normally progress through:

**design → test → evaluate impact → remediate dependencies → enforce → monitor**

Existing resources should also be evaluated separately because not every preventive policy retroactively changes resources that already exist.

---

# Security Evidence

A policy definition by itself is not sufficient evidence that a security requirement is operating effectively.

A production implementation should be able to demonstrate:

* The policy exists
* The policy is assigned at the intended scope
* Subordinate environments inherit it
* Noncompliant deployment attempts are denied where expected
* Approved exceptions are identifiable
* Security administrators cannot casually bypass the control
* Policy changes are logged
* Relevant security events are monitored

This distinction is important:

> **Configured does not automatically mean enforced, and enforced does not automatically mean monitored.**

Layer 1 should therefore integrate with the broader logging, monitoring, compliance, and incident-response architecture.

---

# Production Considerations

Before using these patterns in a production environment, an organization would need to evaluate:

* Existing cloud hierarchy
* Policy inheritance
* Break-glass administration
* Regulatory requirements
* Data residency
* Existing workloads
* Private network dependencies
* Identity dependencies
* Policy deployment strategy
* Exception governance
* Terraform state protection
* Change management
* Monitoring and alerting
* Evidence retention

The specific controls selected should be based on the organization's risk, regulatory obligations, architecture, and operating model rather than applying the strictest available setting by default.

---

## Security Architecture Principle

The security objective of this project can be summarized as:

> **Define the required security outcome centrally, then use the cloud provider's native governance mechanism to enforce that outcome at the appropriate scope.**

AWS SCPs, Azure Policy, GCP Organization Policy, and OCI IAM/Security Zones do not behave identically.

They do not need to.

What matters is that the enterprise can establish, enforce, monitor, and explain its security boundaries consistently across the multicloud environment.
