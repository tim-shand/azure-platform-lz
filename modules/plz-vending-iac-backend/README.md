# Terraform Module: Azure/GitHub IaC Backend Vending

This Terraform module creates Azure and GitHub resources used for Terraform remote state backends, enabling the centralised storage of individual workload state files, located in a _dedicated_ Infrastructure-as-Code Azure subscription. 

---

## 🌟 Features

- Automates the provisioning of required resources for new Terraform backends and secure CI/CD connectivity. 
- Creates a GitHub Actions environment per project, containing project specific variables for project Terraform backend. 
- Creates a project specific Blob Container in the existing Storage Account, within the dedicated IaC Azure subscription. 
- Adds federated credentials (OIDC) for each GitHub Actions environment to the IaC Service Principal in Entra ID. 
- Enables container level RBAC role assignment to manage access and permission to state files. 
- **NOTE:** Requires _MANUAL_ actions:
  - Add the `ARM_SUBSCRIPTION_ID` secret to the new GitHub environments to keep subscription IDs out of code base. 
  - One-time grant admin consent for Service Principal API permissions (`Application.ReadWrite.All`) in Entra ID. 

---

## 📃 Requirements

- **Dedicated IaC Azure Subscription** 
  - Uses a dedicated Infrastructure-as-Code Azure subscription to contain all remote state backend resources. 
- **Azure Service Principal (Entra ID)**
  - Requires `Application.ReadWrite.All` API permission to allow the the Service Principal to update its own credential objects.
- **GitHub PAT Token**
  - Added as GitHub repository secret, referenced by GitHub Actions workflow.
  - Requires read/write access to `actions`, `actions variables`, `administration`, `code`, `environments`, and `secrets`.

**NOTE:** See `variables.tf` for more details. 

- Resource Group name of the Storage Account for IaC backends. 
- Storage Account name for IaC backends. 
- Map of values for GitHub configuration, passed in from GitHub Actions workflow. 
- Name of projects, used to create GitHub environments, provided in TFVARS file.

<!-- BEGIN_TF_DOCS -->
### Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | ~> 3.5.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.40.0 |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.7.5 |

### Resources

| Name | Type |
|------|------|
| [azuread_application_federated_identity_credential.entra_iac_app_cred](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential) | resource |
| [azurerm_storage_container.iac_storage_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [github_actions_environment_variable.gh_repo_env_var](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |
| [github_actions_environment_variable.gh_repo_env_var_key](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |
| [github_repository_environment.gh_repo_env](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment) | resource |
| [azuread_application.this_sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) | data source |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azurerm_storage_account.iac_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_github_env"></a> [create\_github\_env](#input\_create\_github\_env) | Toggle the creation of Github environment and variables. | `bool` | `false` | no |
| <a name="input_github_config"></a> [github\_config](#input\_github\_config) | Map of values for GitHub configuration. | `map(string)` | n/a | yes |
| <a name="input_iac_storage_account_name"></a> [iac\_storage\_account\_name](#input\_iac\_storage\_account\_name) | Storage Account name for IaC backends. | `string` | n/a | yes |
| <a name="input_iac_storage_account_rg"></a> [iac\_storage\_account\_rg](#input\_iac\_storage\_account\_rg) | Resource Group of the Storage Account for IaC backends. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of project for new IaC backend. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_environment_created"></a> [github\_environment\_created](#output\_github\_environment\_created) | Output the variable state: true/false. |
| <a name="output_github_environment_name"></a> [github\_environment\_name](#output\_github\_environment\_name) | If created, output the name of the environment. |
| <a name="output_out_gh_env"></a> [out\_gh\_env](#output\_out\_gh\_env) | Name of the newly created Github environment. |
| <a name="output_out_iac_cn"></a> [out\_iac\_cn](#output\_out\_iac\_cn) | The name of the Container for the IaC backend. |
<!-- END_TF_DOCS -->

---

## ▶️ Usage

1. Add a variable declaration to the root module `variables.tf` file for map of objects. 

```hcl
variable "projects" {
  description = "Map of project config for new IaC backends."
  type = map(object({
    create_github_env = bool # Enable or disable creation of GitHub environment. 
  }))
}
```

2. Add a map of objects called `projects` to the root module `TFVARS` file. This will be used to iterate through each item and deploy IaC backend resources. Each object referenced will be the name used for the environment. 

```hcl
projects = {
  "platformlz" = {
    create_github_env = true # Enable creation of GitHub repository environment.
  }
  "workload-app1" = {
    create_github_env = true
  }
  "workload-app2" = {
    create_github_env = false
  }
}
```

3. Call the child module `vending-iac-backend` from project root module. Supply the required variables to the module declaration. 

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

### Examples

#### Remote State Structure

```markdown
IaC Subscription: mgt-iac-sub
├── Resource Group: mgt-iac-state-rg
│ ├── Storage Account: mgtiacstatesa
│ │ ├── Container: tfstate-platformlz
│ │ ├── Container: tfstate-workload-app1
│ │ └── Container: tfstate-workload-app2

Platform Subscription: mgt-platform-sub
├── Landing Zone resources (network hub, policies, log analytics)

Workload Subscriptions (workload-sub-01)
├── App1 resources

Workload Subscriptions (workload-sub-02)
├── App2 resources
```

#### GitHub Environment Variables

| Environment          | Variable       | Value                           | 
| -------------------- | -------------- | ------------------------------- |
| ** Repository **     | TF_BACKEND_CN  | tfstate-azure-iac               |
| ** Repository **     | TF_BACKEND_KEY | azure-mgt-iac-backends.tfstate  |
| azure-mgt-platformlz | TF_BACKEND_CN  | tfstate-azure-mgt-platformlz    |
| azure-mgt-platformlz | TF_BACKEND_KEY | azure-mgt-platformlz.tfstate    |
| azure-swa-workload01 | TF_BACKEND_CN  | tfstate-azure-app-myapp01       |
| azure-swa-workload01 | TF_BACKEND_KEY | azure-swa-workload01.tfstate    |
