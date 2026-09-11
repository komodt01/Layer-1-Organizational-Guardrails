# Technical Case Study: Designing Multicloud Organizational Guardrails Across AWS, Azure, GCP, and OCI

## Scenario

An enterprise is operating across AWS, Azure, Google Cloud, and Oracle Cloud Infrastructure.

Each provider has a different organizational hierarchy, policy model, and enforcement mechanism, but the enterprise still needs a consistent set of non-negotiable security requirements before workload teams begin deploying resources.

The challenge is not simply writing Terraform for four clouds.

The real architecture problem is:

> How do you translate one enterprise security intent into enforceable preventive controls across four different cloud governance models without assuming the implementations are equivalent?

For this scenario, I treated Layer 1 as the organizational governance boundary.

Layer 1 defines what workload teams are and are not allowed to do.

Layer 2, handled separately, provides the networking, identity, logging, and landing-zone capabilities required to operate within those boundaries.

---

## Architecture Goal

The goal was to establish a common multicloud governance model built around consistent security outcomes.

The main outcomes were:

- Restrict resources to approved locations
- Protect security and audit capabilities from being disabled
- Reduce unnecessary public exposure
- Prevent risky default configurations
- Strengthen identity and administrative controls
- Provide a stricter security profile for higher-risk workloads
- Keep exceptions scoped and intentional

I did not try to force the same technical control into every cloud.

Instead, I used each provider's native governance capabilities to enforce the same broader security intent.

---

## Design Decision: Baseline vs. Strict

One of the first decisions was whether every environment should receive the strongest possible control set.

I decided against that.

A single maximum-security policy set would create unnecessary operational friction and could break workloads that did not require that level of restriction.

Instead, I separated the controls into two profiles.

### Baseline

The baseline profile contains controls that could reasonably apply across a broad enterprise environment.

Examples include:

- Approved deployment locations
- Protection of audit capabilities
- Identity restrictions
- Secure transport requirements
- Prevention of unsafe defaults

### Strict

The strict profile adds controls appropriate for sensitive, regulated, or high-security workloads.

Examples include:

- Private-only access patterns
- Additional protection of security services
- Prevention of public IP assignment
- Stronger network restrictions
- Security Zone enforcement in OCI

The purpose of the strict profile is not to make an environment "more compliant" by default.

It is to make the environment less permissive when the workload risk justifies it.

---

# AWS

## Governance Mechanism

For AWS, the primary Layer 1 mechanism is AWS Organizations Service Control Policies.

SCPs are useful because they establish permission boundaries across accounts without granting permissions themselves.

## Region Restriction

A simple region policy using `Action = "*"` combined with `aws:RequestedRegion` can create unintended problems because some AWS services use global endpoints.

For that reason, I would not apply a blanket regional deny without accounting for global services.

The design instead uses regional restrictions while excluding required global-service actions.

### Why

The control objective is to prevent workloads from appearing in unapproved regions.

The objective is not to accidentally disable IAM, Organizations, Route 53, support services, or other global functionality.

### Architecture Lesson

A technically aggressive guardrail is not automatically a good guardrail.

If it blocks required shared services, it creates operational risk rather than reducing it.

## CloudTrail and AWS Config Protection

I included controls preventing workload administrators from disabling or deleting key audit and configuration capabilities.

Examples include protection against:

- CloudTrail shutdown
- CloudTrail deletion
- AWS Config recorder shutdown
- AWS Config recorder deletion

### Why

If a workload administrator can disable the security telemetry that detects their actions, the governance boundary is weak.

These controls therefore belong at Layer 1 rather than inside the workload itself.

## Organization Membership

Another baseline control prevents member accounts from leaving the AWS Organization.

### Why

Centralized controls only work while the account remains inside the governance hierarchy.

Allowing an account to leave the organization would allow it to escape SCP enforcement entirely.

This is therefore a governance-boundary control, not simply an account administration setting.

## Strict AWS Controls

The strict profile adds protection around security services and storage permissions.

Examples include:

- Preventing S3 ACL changes
- Preventing GuardDuty deletion
- Preventing Security Hub disablement

I intentionally removed an earlier EC2 instance-type restriction.

Restricting instances to values such as `t3.small` and `t3.medium` may be useful for cost or lab standardization, but it is not inherently a security control.

If the business requirement were cost containment, that control could belong in a FinOps or platform-standardization policy instead.

## S3 Public Access

An earlier design attempted to identify public bucket access through ACL-related SCP conditions.

I would not use that as the primary enterprise control.

Public storage exposure is better governed through the platform's dedicated Block Public Access capabilities and the broader storage-governance model.

### Architecture Lesson

Use the provider's strongest native control for the problem rather than forcing a generic policy mechanism to do something it was not designed to do.

---

# Azure

## Governance Mechanism

For Azure, I used Management Groups and Azure Policy.

The Management Group establishes the scope, while policy definitions and assignments provide the enforcement.

## Approved Locations

The baseline profile restricts deployments to approved Azure locations.

The policy also accounts for resources that legitimately use the `global` location.

### Why

A location restriction that fails to account for global resources can create false positives and break otherwise valid platform components.

This is similar to the AWS global-service problem.

The syntax is different, but the architectural issue is the same:

> A location control must reflect how the provider actually represents global services.

## HTTPS Enforcement

The baseline also requires HTTPS for Azure App Service.

An earlier version defined the policy but did not assign it.

That distinction matters.

A policy definition without an assignment expresses intent but does not enforce anything.

### Architecture Lesson

For governance controls, I distinguish between:

- Defined
- Assigned
- Enforced
- Monitored

A control should not be described as implemented simply because a policy definition exists.

## Strict Azure Controls

The strict profile adds:

- Public network access disabled for Azure Storage
- Public network access disabled for Azure Key Vault

These are intentionally stricter than the baseline.

## Dependency on Layer 2

Disabling public access is only safe when the required private connectivity already exists.

For that reason, the strict profile assumes:

- Private Endpoints
- DNS resolution
- Routing
- Administrative access paths
- Required network controls

are already available.

### Failure Scenario

If the Layer 1 policy is applied before Layer 2 private connectivity is ready, a valid security control can make the service inaccessible.

That is why I treat some guardrails as dependent controls rather than isolated Terraform settings.

---

# Google Cloud

## Governance Mechanism

For GCP, I used Organization Policy.

The goal is to enforce requirements above individual projects so that project owners inherit the governance boundary.

## Baseline Identity Controls

The baseline profile includes:

- Prevention of user-managed service-account key creation
- Prevention of automatic IAM grants for default service accounts

### Why

Long-lived service-account keys create persistent credential risk.

Default service accounts can also receive permissions that are broader than necessary.

These controls reduce two common identity risks before workload teams start deploying applications.

## VM IP Forwarding

The baseline prevents arbitrary VM IP forwarding.

### Why

Most application workloads do not need to act as network transit devices.

Allowing IP forwarding by default increases the opportunity for accidental routing, bypass paths, or unmanaged network behavior.

If a firewall, router, appliance, or other network function legitimately requires IP forwarding, that becomes an exception or workload-specific design decision.

## Strict GCP Controls

The strict profile adds:

- Prevention of external IP assignment
- Prevention of default VPC creation
- OS Login requirements

### Why

For high-security projects, I wanted the network and administrative model to be more deliberate.

A project should not automatically receive a default network, and compute workloads should not automatically expose themselves directly to the internet.

OS Login also supports centralized access rather than relying on unmanaged local SSH key patterns.

## Existing-Resource Consideration

An organizational policy may prevent future configurations without automatically correcting every existing resource.

For example, existing workloads with external IP addresses may require separate remediation.

### Architecture Lesson

Preventive policy and remediation are two different functions.

A control can stop new drift while still leaving historical drift that must be addressed separately.

---

# OCI

## Governance Mechanism

OCI required the biggest architectural adjustment.

I initially approached OCI as though its IAM policies could be used exactly like AWS SCPs.

That was the wrong abstraction.

OCI has its own authorization and security-governance model, so I separated the design into:

- IAM policy boundaries
- Security Zones for stronger preventive enforcement

## Baseline OCI Controls

The baseline profile focuses on:

- Regional administrative restrictions
- Controlled Object Storage permissions
- Tenancy-level least privilege

OCI region conditions use region keys such as `PHX` and `IAD` rather than full region names such as `us-phoenix-1` and `us-ashburn-1`.

This is a small implementation detail, but it matters because the governance condition has to use the provider's actual authorization model.

## Why IAM Alone Was Not Enough

Traditional OCI IAM permissions are primarily allow-based.

That means a narrow allow policy does not necessarily create the same type of hard organizational boundary as an AWS SCP.

A broader allow elsewhere can change the resulting authorization posture.

For that reason, I would not claim that an OCI IAM policy is equivalent to an AWS SCP.

## Strict OCI Controls

For the strict profile, I used OCI Security Zones.

Security Zones are a better fit for high-security compartments because they can reject operations that violate the assigned security recipe.

This allows OCI to achieve a similar security outcome through a different enforcement mechanism.

### Assumptions

The strict OCI design assumes:

- Cloud Guard is already enabled
- A strict compartment exists
- An appropriate Security Zone recipe is available

---

# Cross-Cloud Design Comparison

The final architecture intentionally uses different mechanisms across providers.

| Provider | Governance Mechanism | Main Use |
|---|---|---|
| AWS | Organizations SCPs | Account-level permission boundaries |
| Azure | Management Groups + Azure Policy | Resource configuration enforcement |
| GCP | Organization Policy | Organization/project constraint enforcement |
| OCI | IAM Policies + Security Zones | Authorization boundaries and preventive security enforcement |

The implementation differs, but the enterprise requirement remains consistent.

That is the core design principle of the project:

> Standardize the security outcome, not necessarily the implementation mechanism.

---

# Exceptions

A multicloud guardrail model needs an exception process.

Some workloads will legitimately require behavior that the standard profile blocks.

Examples include:

- A workload requiring a different region
- A public-facing service
- A network appliance requiring IP forwarding
- A legacy integration requiring a temporary identity exception
- A workload that cannot immediately move behind private connectivity

I would not solve those requirements by weakening the organization-wide guardrail.

Instead, I would scope the exception as narrowly as possible.

A production exception would include:

- Business justification
- Scope
- Risk
- Compensating controls
- Approver
- Review or expiration date
- Monitoring requirements

---

# Failure Paths

Preventive guardrails can create outages when implemented without dependency analysis.

### Region restriction blocks a required service

A workload depends on a service unavailable in an approved region.

**Result:** deployment fails.

**Architecture response:** determine whether the service requirement is valid, expand the approved-region model if justified, or redesign the workload.

### Public access is disabled before private connectivity exists

A storage service or Key Vault becomes unreachable.

**Result:** application or administrative access fails.

**Architecture response:** establish Private Endpoints, DNS, routing, and operational access before policy enforcement.

### Identity restrictions break automation

An application depends on a long-lived service-account key.

**Result:** deployment or runtime authentication fails.

**Architecture response:** migrate to managed or workload identity rather than disabling the guardrail.

### Security-service protection blocks a valid administrative task

A security team needs to modify or replace a centrally managed control.

**Result:** the administrative operation is denied.

**Architecture response:** use an approved break-glass or security-administration path rather than weakening the workload boundary.

---

# Validation

For this type of architecture, I would not consider a control complete just because Terraform applies successfully.

Validation should confirm:

- The policy exists
- The policy is assigned at the correct scope
- Child accounts, subscriptions, projects, or compartments inherit the expected control
- A prohibited deployment actually fails
- An allowed deployment still succeeds
- Security telemetry captures the event
- Exceptions behave only within their approved scope
- Existing resources are evaluated separately where required

This creates the validation chain:

> Policy defined → policy assigned → policy inherited → policy tested → result observed → evidence retained

---

# Evidence

In a production environment, evidence could include:

- Terraform plans and apply records
- Cloud audit logs
- Organization-policy evaluation results
- Denied deployment events
- Azure Policy compliance results
- GCP Organization Policy state
- AWS Organizations policy attachments
- OCI Security Zone findings
- Exception records
- Remediation records

The goal is to demonstrate that the control is operating, not merely that code exists in a repository.

---

# Tradeoffs

The biggest tradeoff in Layer 1 governance is between central control and workload flexibility.

Too little central governance allows inconsistent security and creates drift.

Too much central governance can block legitimate workload requirements and slow delivery.

That is why I used:

- Baseline controls for broad enterprise use
- Strict controls for higher-risk environments
- Narrow exception paths
- Provider-native enforcement mechanisms
- Explicit dependencies on Layer 2 capabilities

The strongest control is not always the best control.

The better control is the one that reduces meaningful risk without creating unnecessary operational failure.

---

# What I Would Evaluate in Production

Before applying these controls broadly, I would evaluate:

- Existing cloud hierarchy
- Current inherited policies
- Legacy workloads
- Existing public endpoints
- Identity dependencies
- Network dependencies
- Break-glass administration
- Exception workflows
- Logging and monitoring
- Rollback strategy
- Policy testing
- Existing-resource remediation
- Data residency requirements
- Regulatory scope

I would also introduce high-impact policies progressively rather than enabling them across the entire organization at once.

---

# Result

The resulting design creates a consistent Layer 1 governance model across four cloud platforms without pretending those platforms work the same way.

The important outcome is not that AWS, Azure, GCP, and OCI use identical controls.

The outcome is that the enterprise can answer the same questions across all four environments:

- Where may resources be deployed?
- Which security controls may not be disabled?
- Which workloads may be publicly exposed?
- Which identity behaviors are allowed?
- What changes in a high-security environment?
- How are exceptions handled?
- How do we prove the controls are actually working?

That is the purpose of Layer 1 organizational guardrails.
