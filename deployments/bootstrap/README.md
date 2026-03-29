# Bootstrap: Azure & GitHub for Terraform IaC

Automates the **initial bootstrapping** process of both Azure and GitHub, in preparation for executing platform landing zone deployment workflows.

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

---

## Architecture

![Bootstrap resource architecture diagram.](../../docs/images/diagram-bootstrap.png)

---

## 📦 Requirements

- GitHub account with a existing repository for the Azure platform landing zone project.
  - **Roles:** Read/Write access to `actions`, `actions variables`, `administration`, `code`, `environments`, and `secrets`.
- Existing Azure tenant with required roles assigned to a _dedicated_ IaC subscription (can also be used with a single platform subscription).
- **Built-in Roles:** Bootstrap process requires:
  - `Global Administrator`: Required to approve MSGraph application API permissions assigned to the Service Principal.
  - `Contributor`: Required to deploy initial resources.
  - `User Access Administrator`: Required to assign RBAC roles.
  - `App Configuration Data Owner`: Required to access data plane (read/write) for shared services data.
- Applications installed locally (during bootstrap process):
  - **[Terraform](https://developer.hashicorp.com/terraform/install):** IaC tool used to deploy resources into the target Azure and GitHub tenancies.
  - **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest):** CLI tool required by Terraform provider (`AzureRM`) to connect to Azure.
  - **[GitHub CLI](https://cli.github.com/):** CLI tool used to interact with GitHub, connected and authenticated to the target GitHub organisation.
  - **[PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell):** Used to execute the bootstrap automation script locally.

## 🔑 Subscriptions

This design is intended to be used with a **dedicated IaC subscription**, containing and isolating all backend resources from workload subscriptions to reduce the blast radius caused by unwanted subscription changes.

- Requires at least **one existing** subscription to be used as the **IaC** (Infrastructure-as-Code) subscription.
- The subscription provided will be used to contain **all** backend resources for all the platform landing zone.
- Separate subscriptions can be used per deployment stack if required; however, using the same subscription is also accepted.

### Naming Method

- Subscriptions should be named in a way that makes them uniquely identifiable.
- This enables the subscription IDs to be resolved by a Terraform data call, using a **keyword-based** lookup method.
- Although not technically sensitive, this ensures subscription IDs are kept out of variable files, being a public repo.

### Example

Notice that both the `governance` and `identity` stack configurations below are using the **same value** for the `subscription_identifier` field.

Using the same value will result in the **same subscription ID** being used for both stacks.  
The subscription ID is resolved when by a data call made using the value provided by the `subscription_identifier` parameter.

```hcl
platform_stacks = {
  "connectivity" = {
    stack_name              = "plz-connectivity"  # Name of stack directory and GitHub environment.
    stack_code              = "con"               # Short code for the stack name.
    subscription_identifier = "12345678-0000-000" # Subscription ID part, resolved to full ID in data call.
  },
  "governance" = {
    stack_name              = "plz-governance"
    stack_code              = "gov"
    subscription_identifier = "12345678-0000-000"
  },
  "management" = {
    stack_name              = "plz-management"
    stack_code              = "mgt"
    subscription_identifier = "12345678-0000-000"
  }
}
```

---

## 🌱 Resources

### ☁️ Azure

#### Service Principal

- A dedicated identity (App Registration + Service Principal) used to authenticate with Entra ID.
- Executes deployments against the tenant from within automation workflows.
- Uses [OpenID Connect (OIDC)](https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc) for secure authentication, **avoiding** the need for managing client secrets or certificate based authentication.

#### Management Group

- A top-level "core" Management Group is created under the default tenant root group, representing the current organisation hierarchy.
- All existing subscriptions accessible by the user running the bootstrap, will be **moved** under this new Management Group.
- **RBAC** roles assigned at the "core" Management Group level are then inherited by child subscriptions.
- This allows the Service Principal to provision resources, make further changes to Management Group structure, and perform subscription assignments.

#### Remote Backend Resources

- **Resource Groups:**
  - Created per deployment category (platform, workloads) to group related child resources for easy management and separation of purpose.  
- **Storage Accounts:**
  - Similar to Resource Groups, created per deployment category to hold the Blob Containers used by each deployment stack.
- **Blob Containers:**
  - Created per deployment stack to hold the remote Terraform state files per stack.

### 👜 GitHub

- Code repository, version control and automation workflows.
- Entra ID Service Principal details added as repository secrets.
- Azure remote backend resources and subscription details added per deployment stack as secrets and variables.
- Workflows to read individual stack variables/secrets and pass securely to Terraform at workflow run-time.

---

## 📁 Example Structure

Resources are grouped by categories and their child stacks.

- **Categories:**
  - Platform
  - Workload
- **Stacks:**
  - Platform --> Governance (plz-governance)
  - Platform --> Management (plz-management)
  - Platform --> Connectivity (plz-connectivity)

```text
org-platform-iac-rg
└── orgiacplatformsa12345
    ├── tfstate-iac-bootstrap
    ├── tfstate-plz-governance
    ├── tfstate-plz-management
    └── tfstate-plz-connectivity
```

| Object                  | Created Per  | Example Name             | Purpose                                                      |
| ----------------------- | ------------ | ------------------------ | ------------------------------------------------------------ |
| Resource Group          | **Category** | org-iac-platform-rg      | Resource group containing components for platform LZ.        |
| Resource Group          | **Category** | org-iac-workload-rg      | Resource group containing future workload remote states.     |
| Storage Account         | **Category** | orgiacplatformsa12345    | Holds blob containers per platform deployment stack.         |
| Storage Account         | **Category** | orgiacworkloadsa12345    | Holds blob container for bootstrap and global resources.     |
| Blob Container          | **Stack**    | tfstate-iac-bootstrap    | Contains remote state file, created during initial setup.    |
| Blob Container          | **Stack**    | tfstate-plz-governance   | Contains remote state file, referenced by stack workflow.    |
| Blob Container          | **Stack**    | tfstate-plz-management   | Contains remote state file, referenced by stack workflow.    |
| Blob Container          | **Stack**    | tfstate-plz-connectivity | Contains remote state file, referenced by stack workflow.    |

---

## ▶️ Usage

1. Review and populate the Terraform variable files (TFVARS) in the `./variables` directory.
2. Check the required CLI applications are installed **and** authenticated (Azure CLI + GiHub CLI).
3. Execute the PowerShell Bootstrap script to deploy Bootstrap resources and perform remote state migration.
4. \[OPTIONAL\]: Remove all Bootstrap resources (if required).

```shell
# Use Azure CLI to check the ID and Name fields for the current subscription. 
az account show

# [OPTIONAL] Set the correct sunscription (if required). 
az account set --subscription mysubscription

# Deploy Bootstrap resources (will perform update on subsequent runs).
powershell -file ./deployments/bootstrap/bootstrap-azure-github.ps1

# [REMOVAL] Remove Bootstrap resources.
powershell -file ./deployments/bootstrap/bootstrap-azure-github.ps1 -Remove
```

![Bootstrap deployment prompt.](../docs/images/bootstrap_prompt_01.png)

---

## 📚 Reference Materials

A list of references, material and content that contributed to, or influnenced this project.

- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/overview)
- [Terraform Azure Verified Modules](https://azure.github.io/Azure-Landing-Zones/terraform/)
