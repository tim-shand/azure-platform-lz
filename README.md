# Azure: Platform Landing Zone

_Automated, IaC-driven Azure platform landing zone, implementing governance, automation, and targeting operational best practices._

This repository contains a custom Azure platform landing zone (PLZ), providing an enterprise-style environment for hands-on skill development. 
The platform landing zone deploys shared services, providing governance via Azure Policy, and centralized connectivty through a hub-spoke network architecture.  

Designed to be light-weight and cost efficient, utilizing free or low-cost options where possible, while maintaining a minimalistic footprint. 

---

## 🚀 Platform Landing Zone

Deployed and managed using infrastructure as Code (IaC), providing shared resources, connectivity, governance, monitoring and observability, with an aim to align with CAF guidelines and best practices where practical. 

- **[Bootstrapping (Powershell + Terraform)](./deployments/bootstrap)** 
  - Provides the initial setup process to configure Azure and GitHub for automation and IaC. 
  - Using templated Terraform configuration and triggering post-deployment state migration to new resources in Azure. 
  - Creates Entra ID Service Principal:
    - Secured with Federated Credentials (OIDC).
    - Details added as repository secrets and referenced by workflows.  
  - Deploys backend resources into dedicated IaC subscription **per stack**:
    - Maintaining isolation and independence per stack.  
    - Resource Groups and Storage Accounts per category (bootstrap, platform, workloads).
    - One state file per stack (governance, connectivity, management, identity).
  - Configures Azure Key Vault for global output values required across stacks.
    - A single source of truth for critical outputs like Hub VNet ID, Log Analytics Workspace ID, and User Assigned Managed Identity.
- **[Governance](./deployments/plz-governance)**
  - Management groups for policy assignment hierarchy and subscription management. 
  - Automated mapping of subscriptions to target management groups using an identifier value. 
  - RBAC and policy assignments providing guard rails to secure the environment and reduce unwanted spend.  
- **[Management](./deployments/plz-management)**
  - Centralized Log Analytics workspace for monitoring and observability. 
  - Diagnostic settings (applied via policy). 
  - Microsoft Defender for Cloud (Foundational CSPM) providing security posture and recommendations. 
- **[Connectivity](./deployments/plz-connectivity)**
  - Hub-Spoke architecture, providing centralized network management and flow control. 
  - Workload VNets peered as spokes, isolating and securing environments. 
- **[Identity](./deployments/plz-identity)**
  - Create base groups within Entra ID for RBAC assignments. 
  - Automate the creation and management of groups, users, and PIM role assignments. 

---

## ▶️ Deployment Process & Stacks

1. **Bootstrap:** Execute [bootstrap script](./deployments/bootstrap) to begin deployment process. 
2. **Governance:** Deploy Management Group structure and assign policies at management group levels. 
3. **Management:** Create monitoring/observability resources, referenced by policies in Governance stack. 
4. **Connectivity:** Deploy networking resources using a hub-spoke architecture for centralized control. 
5. **Identity:** Deploy core Entra ID groups, RBAC assignments, and managed identities for policy enforcement. 

---

## 🛠️ Tooling & Platforms

- **Terraform:** 
  - Cloud-agnostic Infra-as-Code tool for deploying and managing resources in Azure and GitHub. 
  - Reasoning: Flexibility and wide range of publicly available modules and providers. 
- **Powershell:** 
  - Environment configuration, bootstrapping process, and misc utility scripts. 
  - Reasoning: Readability and existing familiarity with the language. 
- **GitHub + Actions:** 
  - Providing code repository (VCS) and CI/CD workflows for automating deployment of stacks. 
  - Reasoning: Combination of repository and automation in a single platform. 

---
