# ☁️ Azure Platform Landing Zone (Custom)

This project contains a custom Azure platform landing zone (PLZ), inspired by enterprise-scale architecture and based on CAF guidelines.
Designed to be light-weight and cost-efficient, utilizing free or minimum pricing SKU options where possible.
Ideal for a small organization, personal tenant, light production or development/training purposes.

## ✨ Features

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

## 🏢 Architecture & Design

TBC

---

## 🚀 Deployment Stacks

### 🥾 [Bootstrapping](./deployments/bootstrap)

Automates the **initial bootstrapping** process, preparing both Azure and GitHub for platform landing zone deployments.

- **Locally executed Powershell script:**
  - Performs the initial setup process, configuring Azure and GitHub for automation.
  - Performs pre-flight checks, validates authentication and confirms intentions.
  - Executes pre-defined Terraform module to deploy base resources.
  - Adds stack variables and secrets into the provided GitHub repository.
  - Automates the post-deployment migration process of local state file to Azure blob storage providing remote state.
- **Service Principal + OIDC:**
  - Providing a secure authentication method for workflows within GitHub repository.
  - Custom RBAC role assigned providing required permissions for resource management.
- **Backend Resources --> Dedicated IaC Subscription:**
  - Resource Group and Storage Accounts per category (platform, workloads).
  - Maintaining isolation and independence, using separate state files per stack (governance, connectivity, management).

### 📜 [Governance](./deployments/plz-governance)

The Governance stack provides structure and policy enforcement, combining Management Groups with Azure Policy assignments.
This stack lays the ground work for policy assignments and remediation to enforce resource configuration.

- **Management Groups:**
  - Deploy multi-level Management Group structure, defined within the `plz-governance.tfvars` file, allowing for expansion.
  - Management Groups are assigned to a "Level", determining the layer of depth at which each Management Group sits (parent/child).
  - Automated mapping of subscriptions to parent management groups using a subscription ID prefix identifier value.
- **Azure Policy:**
  - Custom policy definitions and initiatives, defined in JSON files and created using Terraform.
  - Policy Initiative Assignments are mapped to Management Groups using the `policy_initiatives` field in the Management Group structure.
  - Built-in Policy Initiatives are resolved by ID and assigned to target Management Groups in the `policy_initiatives_builtin` variable.
  - Remediation tasks enforce policy compliance continuously, ensuring current and future resources are in compliance.

**Example:** Management Group Structure  

```text
TENANT_ROOT
└── abc-core-mg               (Core Management Group)
    ├── abc-platform-mg       (L1: Platform subscriptions)
    ├── abc-workload-mg       (L1: Workload subscriptions)
        ├── abc-online-mg     (L2: Online/Internet-facing workload subscriptions)
        └── abc-corporate-mg  (L2: Internal/business workload subscriptions)
    ├── abc-sandbox-mg        (L1: Dev/test/sandbox subscriptions)
    └── abc-decom-mg          (L1: Holding group for decommissioned subscriptions)
```

```hcl
management_groups_level1 = {
  "platform" = {
    display_name             = "Platform"                                   # Contains all platform subscriptions. 
    parent_mg_name           = "core"                                       # Key ID of the parent Management Group. 
    subscription_identifiers = ["12345678-0000-0000", "12345678-1111-1111"] # List of subscription identifiers, first 3 segments used to resolve full ID.
    policy_initiatives       = [core_baseline]                              # Assign Policy Initiatives directly to MGs. 
  }
  "workload" = {
    display_name             = "Workload"
    parent_mg_name           = "core"
    subscription_identifiers = ["12345678-2222-2222]
    policy_initiatives       = ["cost_controls"] 
  }
}
```

### 🔍 [Management](./deployments/plz-management)

The Management stack deploys and configures the core shared operational services required to run and monitor the Azure Platform Landing Zone.
This stack provides centralized logging, monitoring, alerting, and policy-driven diagnostic configuration for all platform subscriptions.

- **Centralized Logging:**
  - Log Analytics workspace for monitoring and observability of platform resources.
  - Activity, audit and metric logs sent to Log Analytics Workspace for review and retention.
  - Storage Account for long term log archiving.
- **Policy-Driven Diagnostics:**
  - Diagnostic settings applied to resources via Azure Policy assignments.
- **Alerting & Action Groups:**
  - Activity, Service and Health alerting, with category-based action groups.
  - Severity-based notification routing using Action Groups, targeting required support teams.
- **Entra ID Administrative Groups:**
  - Create base administrative groups in Entra ID, to be used with RBAC assignments.
  - Group owners are assigned and resolved dynamically using employee ID lookups.

### 🌐 [Connectivity](./deployments/plz-connectivity)

The Connectivity stack deploys the resources required for secure networking between workloads and on-prem.

- **Hub-Spoke Architecture:**
  - Deploys a hub-spoke network architecture for centralized network management and secure traffic flow.
  - Spoke VNets (workloads) peer to the central hub VNet (platform).
  - Network Security Groups (NSGs) enforce rule-based traffic controls at the subnet levels.
- **Azure Firewall:**
  - Provides centralized network security and traffic inspection for hub and spoke workloads.
  - Management subnet, NIC and public IP, allowing for separation between data and operational traffic.
- **Azure Bastion:**
  - Secure and centralized RDP and SSH connectivity to cloud VMs.
  - Reduce risk by removing the need to expose public IP or endpoints for VM workloads.
- **VPN Gateway:**
  - Site-to-Site VPN for hybrid connectivity between Azure and on-prem.
  - Dedicated subnet providing gateway services for hub virtual network.

---

## ❔ Requirements

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

1. Update variables file in `./variables` with desired inputs.
2. Add subscription name part values to the `iac-bootstrap.tfvars.json` file for each stack reference.
3. **Bootstrap:** Execute [bootstrap script](./deployments/bootstrap) to begin initial configuration process.
4. **Management:** Deploy monitoring and observability resources.
5. **Governance:** Deploy management group structure, policy definitions and initiatives.
6. **Connectivity:** Deploy networking resources using a hub-spoke architecture.

---

## 📕 Naming Convention

This project uses a semi-opinionated naming format for resources to ensure consistency, readability, and CAF alignment.  
Resource names are provided using a custom [naming module](./modules/global-resource-naming/) that produces multiple naming outputs.

**Template:** `<resource_type>-<prefix>-<workload>-<stack_or_env>-<category>-<instance>`  

| Segment         | Purpose / Description                                                                                        |
| --------------- | ------------------------------------------------------------------------------------------------------------ |
| `resource_type` | Azure resource type abbreviation: `rg`, `vnet`, `snet`, `app`, `sql`, `api`, etc.                            |
| `prefix`        | Tenant or project identifier, `abc` (Animal Balloon Company)                                                 |
| `workload`      | `plz` for platform, workload name for apps/services (`mywebapp`)                                             |
| `stack_or_env`  | Platform stack (`gov`, `con`, `mgt`, `idn`) **or** environment (`dev`, `tst`, `stg`, `prd`)                  |
| `category`      | Optional category grouping: `hub`, `fwl`, `bas` (used mainly for PLZ resources, optional for workloads)      |
| `instance`      | Numeric identifier: `01`, `02`, `03` (for multiple similar resources)                                        |

### Examples: Platform

| Resource           | Name Example              |
| ------------------ | ------------------------- |
| Resource Group     | `rg-abc-plz-con-01`       |
| Azure Firewall     | `afw-abc-plz-con-01`      |
| Hub VNet           | `vnet-abc-plz-con-hub`    |
| Firewall Subnet    | `snet-abc-plz-con-afw`    |
| Web App            | `app-abc-mywebapp-prd-01` |
| SQL Database       | `sql-abc-mywebapp-prd-01` |
| Virtual Machine    | `vm-abc-mywebapp-prd-01`  |

---

## 📚 Reference Materials

A list of references, material and content that contributed to, or influenced this project.

- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/overview)
- [Terraform Azure Verified Modules](https://azure.github.io/Azure-Landing-Zones/terraform/)
