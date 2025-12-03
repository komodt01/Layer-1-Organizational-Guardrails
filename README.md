# Multicloud Organizational Guardrails – Layer 1 (Terraform)

This repository contains Terraform examples for implementing **Layer 1 governance controls** across AWS, Azure, Google Cloud, and Oracle Cloud Infrastructure (OCI). This layer represents the organizational and governance boundary of a multi-cloud architecture.

Layer 1 establishes cloud-wide guardrails such as:
- Organization/folder/management group hierarchy
- Tenancy boundaries and compartments
- Enterprise controls applied at the organization scope
- Restrictive policies and baseline governance

Layer 1 is intentionally separate from Layer 2 (account landing zones) and Layer 3 (application/workload platforms) to reflect a clean security separation of concerns.

---

## 🔐 Purpose of Layer 1

Layer 1 enforces **enterprise-level governance** and prevents unsafe or unapproved deployments at the cloud account level.

This layer defines the constructs that sit above any individual project or environment:

- AWS Organizations and Service Control Policies (SCPs)
- Azure Management Groups & Azure Policy
- GCP Organization, Folders, and Org Policy constraints
- OCI compartments and tenancy-level policies

These controls enforce secure defaults and restrict what can be deployed across the entire cloud estate.

---

## 🧱 What This Layer Includes

Each cloud folder includes Terraform examples for:
- Root-level hierarchy and segmentation
- Definition of OU/MG/Folder/Compartment structure
- Example governance and policy enforcement
- Zero hard-coded credentials
- No workload configuration

You can extend this structure with additional governance modules such as:
- Logging accounts
- Budget guardrails
- Allowed regions and services
- Provider-specific security controls

---

## 🧩 Supported Clouds

```
/AWS
/Azure
/GCP
/OCI
```

Each cloud has a `terraform` folder containing:
- `main.tf`
- `provider.tf`
- `variables.tf`

This structure mirrors enterprise landing zone best practices.

---

## 🧠 Why Terraform?

This repo demonstrates:
- Infrastructure-as-Code for organizational governance
- Repeatable, modular, multi-cloud guardrail patterns
- Separation of concerns across architecture layers

Infrastructure governance should be declared, version controlled, and auditable. Terraform provides consistent enforcement across clouds.

---

## 🚦 Relationship to Layer 2 and Layer 3

This repo is Layer 1 of a 3-layer architecture:

- **Layer 1 – Organizational Guardrails (this repo)**  
  Defines cloud-wide restrictions, hierarchy, policies

- **Layer 2 – Landing Zone Baselines**  
  Networking, logging, IAM, segmentation per account/subscription/project

- **Layer 3 – Workloads and Platforms**  
  Applications, clusters, pipelines, compute platforms

By separating the layers, governance and infrastructure become more secure, maintainable, and auditable.

---

## Notes

- This repository is for reference and educational use.
- Placeholder values should be replaced before production use.
- Terraform may require specific identity permissions at the org level.

---

## Author

Multicloud Organizational Guardrails – Layer 1  
Terraform Reference Architecture
