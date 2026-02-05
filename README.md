# Azure Platform Landing Zone

This repository contains a **custom** Azure platform landing zone (PLZ), providing an environment _based_ on enterprise-scale architecture and CAF guidelines.  

Designed to be light-weight and cost efficient, utilizing free or low-cost options where possible, while maintaining a minimalistic footprint. 

Deployed and managed using infrastructure as Code (IaC), this platform landing zone is deployed in stages (stacks), providing governance through Azure Policy, configuring shared services for monitoring and observability, and centralized connectivty through a hub-spoke network architecture. 

---


## 🏢 Architecture & Design

TBC

---


## 🚀 Deployments / Stacks

### 👢 [Bootstrapping](./bootstrap)

- Provides the initial setup process to configure Azure and GitHub for automation and IaC. 
- Using templated Terraform configuration and triggering post-deployment state migration to new resources in Azure. 
- Creates Entra ID Service Principal:
  - Secured with Federated Credentials (OIDC). 
  - Details added as repository variables and referenced by workflows. 
- Deploys backend resources **per stack** into a dedicated IaC subscription:
  - Maintaining isolation and independence per stack. 
  - Resource Groups and Storage Accounts per category (bootstrap, platform, workloads). 
  - One state file per stack (governance, connectivity, management, identity). 
  - Azure App Configuration used to store shared service global outputs (IDs and names) to be used by other stacks. 

### 🏰 [Governance](./deployments/plz-governance)

- Management groups providing Azure Policy assignment hierarchy and subscription management. 
- Automated mapping of subscriptions to target management groups using an identifier value, keeping IDs out of code base. 
- RBAC and policy assignments providing guard rails to secure the environment and reduce unwanted spend. 

### 📊 [Management](./deployments/plz-management)

- Centralized Log Analytics workspace for monitoring and observability. 
- Diagnostic settings applied to resources via Azure Policy. 
- Microsoft Defender for Cloud (Foundational CSPM) providing base level security and recommendations. 

### 📡 [Connectivity](./deployments/plz-connectivity)

- Hub-Spoke architecture, providing centralized network management and flow control. 
- Workload VNets to be peered with the hub VNet as spokes, utilizing User-Defined-Routes (UDR) to direct traffic via Azure Firewall.

### 🤓 [Identity](./deployments/plz-identity)

- Create base groups within Entra ID to be used with RBAC assignments. 
- User-Assigned Managed Identity used to deploy policy configurations such as diagnostic settings to resources. 

---


## 🛠️ Tooling & Platforms

- **Terraform:** 
  - Cloud-agnostic Infra-as-Code tool for deploying and managing resources in Azure and GitHub. 
  - Flexible with a wide range of publicly available modules and providers. 
- **Powershell:** 
  - Automating the bootstrapping tasks, and misc utility scripts. 
  - High readability with extensive user base, cross platform.  
- **GitHub + Actions:** 
  - Providing code repository (VCS) and CI/CD workflows for automating deployment of stacks. 
  - Combination of repository and automation in a single platform. 

---


## ▶️ Deployment Process

1. **Bootstrap:** Execute [bootstrap script](./bootstrap) to begin deployment process. 
2. **Governance:** Deploy Management Group structure and assign policies at management group levels. 
3. **Management:** Create monitoring/observability resources, referenced by policies in Governance stack. 
4. **Connectivity:** Deploy networking resources using a hub-spoke architecture for centralized control. 
5. **Identity:** Deploy core Entra ID groups, RBAC assignments, and managed identities for policy enforcement. 

---


## 📕 Naming Conventions

This project uses a semi-opinionated naming format for resources to ensure consistency, readability, and CAF alignment.  
Resource names are provided using a custom [naming module](./modules/global-resource-naming/) that produces multiple naming outputs. 

**Template:** `<prefix>-<workload>-<stack_or_env>-<category>-<resource_type>-<instance>`  

| Segment         | Purpose / Description                                                                                        |
| --------------- | ------------------------------------------------------------------------------------------------------------ |
| `prefix`        | Tenant or project identifier, `abc` (Animal Balloon Company)                                                 |
| `workload`      | `plz` for platform, workload name for apps/services (`mywebapp`)                                             |
| `stack_or_env`  | Platform stack (`gov`, `con`, `mgt`, `idn`) **or** environment (`dev`, `tst`, `stg`, `prd`)                  |
| `category`      | Optional category grouping: `hub`, `fwl`, `bas` (used mainly for PLZ resources, optional for workloads)      |
| `resource_type` | Azure resource type abbreviation: `rg`, `vnet`, `snet`, `app`, `sql`, `api`, etc.                            |
| `instance`      | Numeric identifier: `01`, `02`, `03` (for multiple similar resources)                                        |

### Examples: Platform

| Resource                    | Name Example              | Notes                               |
| --------------------------- | ------------------------- | ----------------------------------- |
| Connectivity Resource Group | `abc-plz-con-rg-01`       | Resource Group for hub connectivity |
| Azure Firewall              | `abc-plz-con-fwl-01`      | Azure Firewall or NVA appliance     |
| Hub VNet                    | `abc-plz-con-hub-vnet-01` | Central hub virtual network         |
| Bastion Subnet              | `abc-plz-con-bas-snet-01` | Subnet for Azure Bastion            |
| VPN Gateway Subnet          | `abc-plz-con-gwy-snet-01` | Subnet for VPN Gateway              |
| Firewall Subnet             | `abc-plz-con-fwl-snet-01` | Subnet for Azure Firewall           |
| Management Subnet           | `abc-plz-con-mgt-snet-01` | Subnet for monitoring/management    |

### Examples: Workload

| Resource     | Name Example              | Notes                            |
| ------------ | ------------------------- | -------------------------------- |
| Web App      | `abc-mywebapp-prd-app-01` | Category omitted for simplicity  |
| SQL Database | `abc-mywebapp-prd-sql-01` | Environment identifies lifecycle |
| API Function | `abc-mywebapp-prd-api-01` | Category omitted, optional       |

### Abbreviation Reference: Categories 

| Abbreviation | Meaning                   |
| ------------ | ------------------------- |
| hub          | Hub network               |
| bas          | Bastion subnet            |
| gwy          | VPN Gateway subnet        |
| fwl          | Firewall / Azure Firewall |
| mgt          | Management subnet         |

### Abbreviation Reference: Resource Types 

| Abbreviation | Meaning               |
| ------------ | --------------------- |
| rg           | Resource Group        |
| vnet         | Virtual Network       |
| snet         | Subnet                |
| app          | App Service / Web App |
| sql          | SQL Database          |
| api          | API / Function        |

---

## ➕ To Do / Future Updates

- [ ] Docs: Platform architecture diagram
- [ ] Stack: Governance
- [ ] Stack: Management
- [ ] Stack: Connectivity
- [ ] Stack: Identity

---


## 📚 Reference Materials

A list of references, material and content that contributed to, or influnenced this project. 

- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/overview)
- [Terraform Azure Verified Modules](https://azure.github.io/Azure-Landing-Zones/terraform/)

