# Compliance Mapping — Illustrative

## Purpose

This document provides an **illustrative mapping** between the Layer 1 organizational guardrails in this repository and selected security and compliance frameworks.

The mappings show how preventive cloud governance controls may **support** broader control objectives.

They do not demonstrate or certify compliance with NIST 800-53, ISO/IEC 27001, CIS Controls, PCI DSS, or any other framework.

Formal compliance requires additional administrative, technical, operational, evidentiary, and risk-management processes beyond the Terraform examples in this repository.

---

# Layer 1 Control Areas

The organizational guardrails in this project primarily address the following security areas:

* Organizational policy enforcement
* Least privilege and identity restrictions
* Approved deployment locations
* Network and public-exposure restrictions
* Protection of logging and security services
* Secure configuration
* Centralized governance
* Prevention of unauthorized security-control changes

The exact enforcement mechanism differs by cloud provider.

| Cloud | Primary Layer 1 Mechanism                  |
| ----- | ------------------------------------------ |
| AWS   | AWS Organizations Service Control Policies |
| Azure | Management Groups and Azure Policy         |
| GCP   | Organization Policy                        |
| OCI   | IAM Policies and Security Zones            |

---

# NIST SP 800-53

Layer 1 guardrails may support objectives within several NIST SP 800-53 control families.

## Access Control — AC

Relevant areas include:

* **AC-3 — Access Enforcement**
* **AC-6 — Least Privilege**

Examples from this project include organizational permission boundaries, service-account restrictions, controlled administrative permissions, and prevention of unauthorized security-control changes.

## Configuration Management — CM

Relevant areas include:

* **CM-2 — Baseline Configuration**
* **CM-6 — Configuration Settings**
* **CM-7 — Least Functionality**

Baseline and strict governance profiles establish centrally defined configuration boundaries and restrict selected configurations that do not meet enterprise security requirements.

## Audit and Accountability — AU

Relevant areas include:

* **AU-9 — Protection of Audit Information**

AWS controls that prevent CloudTrail and AWS Config capabilities from being disabled demonstrate the principle of protecting security and audit mechanisms from unauthorized modification.

Additional logging architecture would be required to satisfy broader audit and accountability requirements.

## System and Communications Protection — SC

Relevant areas include:

* **SC-7 — Boundary Protection**
* **SC-8 — Transmission Confidentiality and Integrity**

Examples include public-network restrictions, external-IP restrictions, network configuration controls, and HTTPS enforcement.

## Assessment, Authorization and Monitoring — CA

Relevant areas include:

* **CA-7 — Continuous Monitoring**

Layer 1 policy enforcement can contribute to a continuous-monitoring program by establishing centrally governed configuration requirements.

The policies themselves do not constitute a complete continuous-monitoring capability.

---

# ISO/IEC 27001:2022 Annex A

The Layer 1 architecture may support objectives associated with several ISO/IEC 27001:2022 Annex A controls.

## Organizational Controls

Relevant areas include:

* **A.5.1 — Policies for information security**
* **A.5.15 — Access control**
* **A.5.16 — Identity management**
* **A.5.23 — Information security for use of cloud services**

Centralized cloud guardrails provide a technical mechanism for translating selected enterprise security requirements into cloud-platform restrictions.

## Technological Controls

Relevant areas include:

* **A.8.2 — Privileged access rights**
* **A.8.9 — Configuration management**
* **A.8.15 — Logging**
* **A.8.20 — Networks security**
* **A.8.21 — Security of network services**
* **A.8.24 — Use of cryptography**

Examples include least-privilege administration, protection of logging capabilities, public-network restrictions, secure configuration requirements, and HTTPS enforcement.

These technical controls represent only part of the evidence and processes required by an ISO/IEC 27001 information security management system.

---

# CIS Critical Security Controls

Layer 1 guardrails may also support several CIS Critical Security Controls.

## CIS Control 4 — Secure Configuration of Enterprise Assets and Software

Organizational policies establish configuration boundaries before cloud resources are deployed.

Examples include:

* Approved locations
* Public-access restrictions
* Network configuration restrictions
* HTTPS requirements
* Strict security profiles

## CIS Control 5 — Account Management

Identity restrictions and centralized administrative boundaries support stronger control over cloud identities and privileged access.

## CIS Control 6 — Access Control Management

Least-privilege policies, service-account restrictions, and organizational permission boundaries support centralized access-control objectives.

## CIS Control 8 — Audit Log Management

Protection of cloud audit and configuration-monitoring services supports the integrity and availability of security telemetry.

The Layer 1 policies do not themselves provide the complete logging lifecycle.

## CIS Control 12 — Network Infrastructure Management

Controls restricting external IPs, public network exposure, default networks, and unmanaged network behavior support secure network governance.

---

# PCI DSS

Layer 1 guardrails may also contribute to PCI DSS security objectives when cloud resources are part of a cardholder data environment.

Relevant areas include:

* Secure network configuration
* Protection of systems from unnecessary public exposure
* Strong access control
* Secure configuration
* Protection and availability of audit mechanisms
* Encryption of data in transit

These guardrails alone do **not** establish a PCI DSS-compliant cardholder data environment.

PCI DSS scope, segmentation, vulnerability management, logging, testing, identity governance, operational procedures, evidence, and other requirements would need to be addressed separately.

---

# Control-to-Architecture Examples

| Layer 1 Guardrail               | Security Objective                            | Example Framework Relationship |
| ------------------------------- | --------------------------------------------- | ------------------------------ |
| Approved regions/locations      | Control resource placement and data residency | NIST CM / ISO A.5.23           |
| CloudTrail protection           | Preserve audit capability                     | NIST AU / ISO A.8.15 / CIS 8   |
| AWS Config protection           | Preserve configuration visibility             | NIST CM / CA                   |
| HTTPS enforcement               | Protect data in transit                       | NIST SC-8 / ISO A.8.24         |
| Service-account key restriction | Reduce persistent credential risk             | NIST AC-6 / ISO A.5.16         |
| Public network restrictions     | Reduce unnecessary exposure                   | NIST SC-7 / ISO A.8.20         |
| External-IP restrictions        | Strengthen network boundaries                 | NIST SC-7 / CIS 12             |
| Security Zone enforcement       | Prevent insecure configurations               | NIST CM / ISO A.8.9            |
| Security-service protection     | Prevent weakening of security controls        | NIST CM / CA                   |

These relationships are illustrative and should be validated against the organization's specific framework version, scope, control implementation, and assessment requirements.

---

# Compliance Evidence

A Terraform policy definition is **not by itself compliance evidence**.

A production governance program would need evidence showing that controls are operating as intended.

Examples include:

* Policy definitions
* Policy assignments
* Organizational hierarchy and scope
* Terraform deployment records
* Policy-change audit logs
* Denied deployment events
* Compliance evaluation results
* Approved exceptions
* Exception expiration and review records
* Remediation records
* Security monitoring results

This creates an important distinction:

**Control intent → technical implementation → enforcement → monitoring → evidence**

Compliance assessment depends on the complete chain rather than simply proving that policy code exists.

---

# Exceptions and Compensating Controls

Some workloads may require approved exceptions to standard organizational guardrails.

A production compliance process should document:

* Business justification
* Applicable requirement
* Scope of the exception
* Risk created by the exception
* Compensating controls
* Approval
* Monitoring requirements
* Expiration or review date

Exceptions should be scoped as narrowly as practical rather than weakening the organization-wide control for every workload.

---

# Scope and Limitations

This repository demonstrates selected **preventive technical governance controls**.

It does not provide:

* A complete information security management system
* Formal risk assessment
* Full framework implementation
* Complete identity governance
* Complete logging or SIEM architecture
* Vulnerability management
* Incident response
* Business continuity
* Compliance testing
* Audit evidence packages
* Formal control ownership
* Certification or attestation

Those capabilities would exist elsewhere within an enterprise security and governance program.

---

## Intent of This Mapping

The purpose of this mapping is to demonstrate how architectural requirements and compliance objectives can influence **cloud governance design**.

The relationship is not:

**Framework control → Terraform = compliant**

It is:

**Framework and risk requirements → security objective → architecture decision → preventive guardrail → operational evidence**

Layer 1 provides one technical part of that larger governance and compliance model.
