# Terraform Module: Azure/GitHub IaC Backend Vending

This Terraform module creates Azure and GitHub resources used for Terraform remote state backends, enabling the centralized storage of individual workload state files, located in a _dedicated_ Infrastructure-as-Code Azure subscription.  

---

# 🌟 Features

- Automates the provisioning of required resources for new Terraform backends and secure CI/CD connectivity. 
- Creates a GitHub Actions environment per workload, containing workload specific variables for workload Terraform backend. 
- Creates a workload specific Blob Container in the existing Storage Account, within the dedicated IaC Azure subscription. 
- Adds federated credentials (OIDC) for each GitHub Actions environment to the IaC Service Principal in Entra ID. 
- Enables container level RBAC role assignment to manage access and permission to state files. 
- **NOTE:** Requires _MANUAL_ actions:
  - Add the `ARM_SUBSCRIPTION_ID` secret to the new GitHub environments to keep subscription IDs out of code base. 
  - One-time grant admin consent for Service Principal API permissions (`Application.ReadWrite.All`) in Entra ID. 

---

# 📃 Requirements

- **Dedicated IaC Azure Subscription** 
  - Uses a dedicated Infrastructure-as-Code Azure subscription to contain all remote state backend resources. 
- **Azure Service Principal (Entra ID)**
  - Requires `Application.ReadWrite.All` API permission to allow the the Service Principal to update its own credential objects.
- **GitHub PAT Token**
  - Added as GitHub repository secret, referenced by GitHub Actions workflow.
  - Requires read/write access to `actions`, `actions variables`, `administration`, `code`, ``environments`, and `secrets`.

---

# ▶️ Usage

```hcl
module "vending_iac_backends" {
  for_each                 = var.projects # Repeat for all listed in terraform.tfvars
  source                   = "../../../../modules/azure/vending-iac-backend"
  iac_storage_account_rg   = var.iac_storage_account_rg   # Resource Group for dedicated IaC. 
  iac_storage_account_name = var.iac_storage_account_name # Storage Account name for dedicated IaC. 
  github_config            = var.github_config            # Map of GitHub configurations values (passed in via GHA workflow). 
  project_name             = each.key                     # Prefixed with "tfstate": tfstate-proxmox
  create_github_env        = each.value.create_github_env # Create Github resources TRUE/FALSE.
}
```

## Inputs

**NOTE:** See `variables.tf` for more details. 

- Resource Group name of the Storage Account for IaC backends. 
- Storage Account name for IaC backends. 
- Map of values for GitHub configuration, passed in from GitHub Actions workflow. 
- Name of projects, used to create GitHub environments, provided in TFVARS file. 

---

## Examples

### Remote State Structure

```markdown
IaC Subscription: mgt-iac-sub
├── Resource Group: mgt-iac-state-rg
│ ├── Storage Account: mgtiacstatesa
│ │ ├── Container: tfstate-platform
│ │ ├── Container: tfstate-workload-app1
│ │ └── Container: tfstate-workload-app2

Platform Subscription: mgt-platform-sub
├── Landing Zone resources (network hub, policies, log analytics)

Workload Subscriptions (workload-sub-01)
├── App1 resources

Workload Subscriptions (workload-sub-02)
├── App2 resources
```

### GitHub Environment Variables

| Environment          | Variable       | Value                           | 
| -------------------- | -------------- | ------------------------------- |
| ** Repository **     | TF_BACKEND_CN  | tfstate-azure-iac               |
| ** Repository **     | TF_BACKEND_KEY | azure-mgt-iac-backends.tfstate  |
| azure-mgt-platformlz | TF_BACKEND_CN  | tfstate-azure-mgt-platformlz    |
| azure-mgt-platformlz | TF_BACKEND_KEY | azure-mgt-platformlz.tfstate    |
| azure-swa-workload01 | TF_BACKEND_CN  | tfstate-azure-app-myapp01       |
| azure-swa-workload01 | TF_BACKEND_KEY | azure-swa-workload01.tfstate    |

---
