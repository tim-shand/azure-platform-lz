# ☁️ Azure Platform Landing Zone (Custom)

This project contains a custom Azure platform landing zone (PLZ), inspired by enterprise-scale architecture and based on CAF guidelines.  
Designed to be light-weight and cost-efficient, utilizing free or minimum pricing SKU options where possible.  
Ideal for a small organization, personal tenant, light production or development/training purposes.

- **Infrastructure as Code (IaC) + CI/CD**
  - Git-driven workflow, with a merge or commit to the `main` branch triggering automation pipelines.
  - Desired state of environment declared in code, using Terraform to define Azure resources and components.
  - Secrets and variables stored in GitHub repository, referenced and passed during workflow run-time.
- **State Segmentation**
  - Utilizes a dedicated subscription, containing state files remotely in Azure Blob storage.
  - Separate state files per deployment stack, reducing blast radius in case of corruption or loss.
- **Powershell Bootstrapping**
  - Locally executed [Powershell script](./deployments/bootstrap) automates initial setup process.
  - Prepares both Azure tenant and GitHub repository for automated deployments using Terraform.

---

## 🚀 Deployment Stacks

### 🛠️ [Bootstrapping](./deployments/bootstrap)

Automates the **initial bootstrapping** process, preparing both Azure and GitHub for platform landing zone deployments.

- Locally executed Powershell script performs the initial setup process, configuring Azure and GitHub for automation.
  - Performs pre-flight checks, validates authentication and confirms intentions.
- Executes pre-defined Terraform module to deploy base resources.
- Creates Entra ID Service Principal:
  - Secured with Federated Credentials (OIDC) for GitHub repository and environments.
  - Custom RBAC role assigned at core management group level.
- Deploys backend resources **per stack** into a dedicated IaC subscription:
  - Resource Groups and Storage Accounts per category (platform, workloads).
  - Maintaining isolation and independence, using separate tate files per stack (governance, connectivity, management).
- Adds stack variables and secrets into the provided GitHub repository.
- Automates the post-deployment migration process of local state file to Azure blob storage providing remote state.

### 📜 [Governance](./deployments/plz-governance)

- Multi-level Management Groups providing Azure Policy assignment and subscription hierarchy.
- Automated mapping of subscriptions to target management groups using a subscription identifier value.
- Custom policy definitions and initiatives, defined in JSON and deployed using Terraform.

### 🔍 [Management](./deployments/plz-management)

The Management stack deploys and configures the core shared operational services required to run and monitor the Azure Platform Landing Zone.
This stack provides centralized logging, monitoring, alerting, and policy-driven diagnostic configuration for all platform subscriptions.

- **Centralized Logging:**
  - Log Analytics workspace for monitoring and observability of platform resources.
  - Activity, audit and metric logs sent to Log Analytics Workspace for review and retention.
  - Storage Account for long term log archiving.
- **Policy-Driven Diagnostics:**
  - Diagnostic settings applied to resources via Azure Policy assignments.
  - Remediation tasks enforce policy compliance continuously, ensuring current and future resources are monitored.
- **Alerting & Action Groups:**
  - Activity, Service and Health alerting, with category-based action groups.
  - Severity-based notification routing using Action Groups, targeting required support teams.
- **Entra ID Administrative Groups:**
  - Create base administrative groups in Entra ID, to be used with RBAC assignments.
  - Group owners are assigned and resolved dynamically using employee ID lookups.

### 🌐 [Connectivity](./deployments/plz-connectivity)

- Implements a hub-and-spoke network architecture for centralized network management and secure traffic flow.
- Spoke VNets connect to the hub VNet using VNet peering, with optional User-Defined Routes (UDRs) directing traffic through Azure Firewall.
- Azure Firewall provides optional centralized network security and traffic inspection for hub and spoke workloads.
- Azure Bastion enables secure RDP/SSH access to VMs in peered VNets without exposing public endpoints or requiring public IPs.
- Network Security Groups (NSGs) enforce fine-grained, rule-based traffic controls at the subnet levels.

---

## 🏢 Architecture & Design

TBC

---

## 📦 Requirements

- GitHub account with a existing repository for the Azure platform landing zone project.
  - **Roles:** Read/Write access to `actions`, `actions variables`, `administration`, `code`, `environments`, and `secrets`.
- Existing Azure tenant with required roles assigned to a _dedicated_ IaC subscription (can also be used with a single platform subscription).
  - **Built-in Roles:** Bootstrap process requires:
    - `Global Administrator` (preferred): Required to approve MSGraph application API permissions assigned to the Service Principal.
    - `Contributor`: Required to deploy initial resources.
    - `User Access Administrator`: Required to assign RBAC roles.
- Applications installed locally (during bootstrap process):
  - **[Terraform](https://developer.hashicorp.com/terraform/install):**
    - Cloud-agnostic Infra-as-Code tool for deploying and managing resources in Azure and GitHub.
    - Flexible with a wide range of publicly available modules and providers.
  - **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest):**
    - CLI tool required by Terraform provider (`AzureRM`) to interact with Azure API.
  - **[GitHub CLI](https://cli.github.com/):**
    - CLI tool used to interact with GitHub, connected and authenticated to the target GitHub organisation.
    - Providing code repository and CI/CD workflows (GitHub Actions) for automating deployment of stacks.
  - **[PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell):**
    - Used to execute the bootstrap automation script locally.
    - High readability with extensive user base, cross platform.

---

## ▶️ Deployment

Stacks are deployed using GitHub Actions workflows located in `.github/workflows`.  
Workflows are designed to be run in the order provided below for the **initial deployment** only.  
Once the full stack list has been deployed, changes can be made, with individual workflows executed when required.

1. **Bootstrap:** Execute [bootstrap script](./deployments/bootstrap) to begin deployment process.
2. **Management:** Create monitoring and observability resources, policy assignments using initiatives from Governance stack.
3. **Governance:** Assign base policies at defined management group and subscription structure.
4. **Connectivity:** Deploy networking resources using a hub-spoke architecture for centralized flow control.

---

## 📕 Naming Convention

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

## 📚 Reference Materials

A list of references, material and content that contributed to, or influenced this project.

- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/overview)
- [Terraform Azure Verified Modules](https://azure.github.io/Azure-Landing-Zones/terraform/)
