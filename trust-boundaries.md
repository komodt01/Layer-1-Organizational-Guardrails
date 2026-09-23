# Governance Authority and Trust Boundaries

## Why the Boundary Exists

Layer 1 guardrails establish a security boundary between the teams that define enterprise cloud requirements and the workload teams operating inside those requirements.

The central question is not simply:

> Which policy should be configured?

It is:

> **Who has authority to define the boundary, where is that boundary enforced, who inherits it, and how can legitimate exceptions occur without weakening governance for everyone else?**

Across AWS, Azure, GCP, and OCI, the technical mechanisms differ, but the authority model follows a similar pattern:

```text
Enterprise Security / Governance Authority
                    |
                    v
        Organizational Policy Plane
                    |
                    v
          Cloud Governance Hierarchy
                    |
                    v
             Workload Boundary
                    |
                    v
       Accounts / Subscriptions /
        Projects / Compartments
```

The Layer 1 boundary exists above individual workloads so that workload administrators cannot simply choose whether enterprise requirements apply to them.

---

## Enterprise Security Authority

The first trust boundary is organizational rather than technical.

Enterprise security, cloud governance, or another authorized control owner determines which security outcomes should apply across the cloud estate.

Examples in this project include:

* Approved deployment locations
* Protection of audit capabilities
* Restrictions on persistent credentials
* Public-exposure limitations
* Protection of centralized security services
* Higher-security requirements for sensitive environments

The repository demonstrates the technical expression of these requirements.

It does not implement the enterprise process that authorizes policy changes, approves guardrails, or assigns administrative ownership.

In production, authority to modify Layer 1 controls should itself be tightly governed because changing an organizational guardrail can affect many subordinate environments simultaneously.

---

## Organizational Policy Plane

Enterprise requirements cross into each cloud through a provider-specific governance mechanism.

| Provider | Layer 1 Enforcement Mechanism              |
| -------- | ------------------------------------------ |
| AWS      | AWS Organizations Service Control Policies |
| Azure    | Management Groups and Azure Policy         |
| GCP      | Organization Policy                        |
| OCI      | IAM Policies and Security Zones            |

These mechanisms should not be treated as technically equivalent.

Their common architectural role is to move security decisions above individual workload administration.

For example, an application team may administer resources inside its AWS account or Azure subscription while still being unable to override an organizational restriction imposed above that environment.

This creates a deliberate separation between:

**workload administration** and **governance authority**.

---

## Inheritance Is Part of the Security Boundary

A guardrail is useful only if it reaches the environments it is intended to govern.

The relevant path is therefore:

```text
Policy Intent
     |
     v
Organizational Scope
     |
     v
Policy Assignment / Attachment
     |
     v
Inheritance
     |
     v
Workload Enforcement
```

A policy definition existing in Terraform is not sufficient evidence that a workload is governed.

The architecture must distinguish between a control that is:

* Defined
* Deployed
* Assigned or attached
* Inherited
* Enforced
* Tested
* Monitored

A failure anywhere in that chain can create a governance gap.

This is particularly important in multicloud environments because inheritance behavior and organizational hierarchy differ between providers.

---

## The Workload Administration Boundary

Workload teams require enough authority to build and operate applications.

They should not automatically receive enough authority to remove the enterprise controls governing those applications.

Layer 1 therefore creates an administrative boundary around subordinate environments.

Examples include:

### AWS

A member account can operate within permissions available to it, while SCPs constrain the maximum permissions available through that account.

The project also demonstrates protection against member accounts leaving centralized organizational governance.

### Azure

Subscription and resource administrators operate beneath Management Group policy assignments.

A workload administrator may manage a resource while still being prevented from deploying configurations denied by inherited Azure Policy.

### GCP

Project-level administration operates beneath Organization Policy constraints inherited from higher levels of the resource hierarchy.

Project ownership therefore does not automatically imply authority to override organizational constraints.

### OCI

OCI requires a different interpretation.

IAM policies determine authorization, while Security Zones can provide stronger preventive enforcement for protected compartments.

Because OCI IAM is primarily allow-based, a narrow IAM policy should not be assumed to create the same hard boundary as an AWS SCP.

Effective permissions must be evaluated across the applicable policy set.

---

## Baseline and Strict Boundaries

This project intentionally does not apply one maximum-restriction profile everywhere.

Instead, it models two governance levels.

### Baseline

Baseline controls establish broadly applicable enterprise boundaries.

They are intended to reduce common risk while preserving enough flexibility for normal workload operation.

### Strict

Strict controls narrow the permitted operating space for sensitive, regulated, or higher-risk workloads.

Examples include stronger public-network restrictions, additional security-service protection, external-IP restrictions, and OCI Security Zone enforcement.

The boundary therefore changes according to the risk profile of the environment.

```text
Enterprise Requirements
        |
        +---- Baseline Boundary ----> General Enterprise Workloads
        |
        +---- Strict Boundary ------> Higher-Risk Workloads
```

Strict does not automatically mean better.

A stricter boundary can create operational failure when its dependencies are not ready.

---

## Layer 1 Depends on Layer 2

Some organizational controls rely on capabilities that Layer 1 does not provide.

For example:

```text
Layer 1
Disable Public Access
        |
        v
Requires
        |
        v
Layer 2
Private Connectivity + DNS + Routing + Administrative Access
```

If the preventive guardrail is enforced before the supporting architecture exists, the control can make a legitimate workload unavailable.

Examples include:

* Azure Storage with public network access disabled before Private Endpoint connectivity exists
* Azure Key Vault with no viable private administrative path
* GCP workloads denied external IP addresses before private ingress and egress are available
* Regional restrictions applied without accounting for required global or provider-specific services

This is an important trust-boundary dependency.

Layer 1 determines what is permitted.

Layer 2 must provide a viable architecture that operates within those restrictions.

---

## The Exception Boundary

Enterprise guardrails cannot assume that every workload has identical requirements.

A legitimate exception should cross the governance boundary through an explicit process rather than through uncontrolled policy weakening.

Conceptually:

```text
Workload Requirement
        |
        v
Exception Request
        |
        v
Risk Evaluation
        |
        v
Authorized Decision
        |
        +---- Denied
        |
        +---- Approved
                 |
                 v
        Narrowly Scoped Exception
                 |
                 v
        Monitoring + Expiration
```

The repository does not implement a formal exception-management system.

For production use, an exception would normally identify:

* Business justification
* Affected workload
* Requested deviation
* Risk
* Compensating controls
* Approver
* Scope
* Monitoring requirements
* Review or expiration date

The objective is to preserve the organizational boundary while allowing controlled deviations where the business requirement justifies them.

---

## Privileged Governance Changes

Layer 1 administrators represent a high-impact privileged role.

A compromised or misused governance identity could potentially:

* Remove preventive controls
* Expand permitted deployment regions
* Re-enable public exposure
* Weaken identity restrictions
* Disable protection of security services
* Change the scope of policy assignments
* Create overly broad exceptions

Production architecture should therefore treat governance-plane administration as a separate privileged function.

Considerations would include:

* Least-privilege administrative roles
* Strong authentication
* Separation of duties
* Controlled policy deployment
* Peer review
* Protected Terraform state
* Change logging
* Break-glass procedures
* Monitoring of policy changes

These governance controls are production considerations and are not fully implemented by this repository.

---

## Failure and Bypass Paths

The most important failure paths are not limited to Terraform errors.

### Policy Exists but Is Not Assigned

The repository contains the intended control, but the organizational hierarchy does not receive it.

**Security consequence:** documented intent exists without enforcement.

### Incorrect Organizational Scope

A policy is attached at the wrong level.

**Security consequence:** some accounts, subscriptions, projects, or compartments may fall outside the intended boundary.

### Workload Moves Outside the Governed Hierarchy

A subordinate environment escapes the organizational structure responsible for enforcement.

**Security consequence:** inherited controls may no longer apply.

The AWS implementation specifically includes a control intended to prevent member accounts from leaving centralized organizational governance.

### Exception Becomes Permanent

A temporary business requirement is approved but never reviewed or removed.

**Security consequence:** the exception becomes an unmanaged alternate security posture.

### Guardrail Is Weakened to Solve One Workload Problem

A centralized restriction blocks a legitimate workload, and the organization responds by weakening the policy globally.

**Security consequence:** solving one workload problem expands risk across unrelated environments.

The preferred response is a narrowly scoped exception or an architectural change where the provider supports it.

### Supporting Architecture Is Missing

A preventive control requires private connectivity, identity integration, DNS, or another Layer 2 capability that is not available.

**Operational consequence:** the security control succeeds technically while the workload fails operationally.

---

## Evidence Across the Boundary

A governance architecture should be able to demonstrate more than the existence of Terraform code.

Useful evidence includes:

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
Inherited Enforcement
    |
    v
Test Result
    |
    v
Audit Evidence
```

Production evidence could include:

* Terraform plans and apply records
* Policy attachments and assignments
* Organizational hierarchy records
* Denied deployment events
* Azure Policy compliance results
* GCP Organization Policy state
* AWS Organizations policy attachments
* OCI Security Zone findings
* Policy-change audit logs
* Approved exception records

This establishes traceability from enterprise requirement to actual enforcement.

---

## Architecture Takeaway

Layer 1 security is fundamentally about **governance authority**.

The enterprise defines a required security outcome.

The cloud governance plane translates that requirement into a provider-native control.

The organizational hierarchy determines who inherits it.

The workload operates inside the resulting boundary.

Exceptions cross that boundary only through deliberate governance.

The resulting model is:

```text
Security Requirement
        |
        v
Governance Authority
        |
        v
Provider-Native Guardrail
        |
        v
Organizational Inheritance
        |
        v
Workload Constraint
        |
        +---- Normal Operation
        |
        +---- Governed Exception
```

The implementation mechanisms differ across AWS, Azure, GCP, and OCI, but the architecture question remains the same:

> **Can the enterprise establish a security boundary above the workload, prove that the workload inherits it, and prevent that boundary from being casually bypassed?**
