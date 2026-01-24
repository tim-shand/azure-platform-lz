# Bootstrap: Azure & GitHub Actions for Terraform IaC Management

_Run-once Powershell/Terraform deployment to bootstrap Azure and GitHub for IaC and CI/CD management._

This bootstrap deployment will create resources in both Azure and GitHub, required for future deployments using Github Actions workflows, allowing for centralized storage of platform state files. All state files can be managed from a single IaC subscription.

## 🌟 Features

- Creates deployment stack resources to deploy an Azure platform landing zone. 
- Generates `global.tfvars` and `bootstrap.tfvars` files using template files (`*.tmpl`). 
- Automates initial bootstrapping process using combination of Powershell and Terraform executed locally. 
- Automates the bootstrap state migration post-setup, from local to newly created Azure resources. 
- Configures Azure Key Vault for global output values required across stacks.
  - A single source of truth for critical outputs like Hub VNet ID, Log Analytics Workspace ID, and User Assigned Managed Identity.

---

## 📗 Requirements

### Accounts

- **Azure:** Existing Azure account with required roles assigned to a _dedicated_ subscription for IaC.
  - **Roles:** `Contributor`, `User Access Administrator`, `[optional] Global Admin`. 
- **GitHub:** Existing GitHub account with a repository for the Azure project.
  - **Roles:** Read and Write access to `actions`, `actions variables`, `administration`, `code`, `environments`, and `secrets`.  

### Required Applications (Installed & Authenticated Locally)

- **[Terraform](https://developer.hashicorp.com/terraform/install):** Used to deploy resources to target Azure environment.
- **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest):** Required by Terraform `AzureRM` provider to connect to Azure.
- **[GitHub CLI](https://cli.github.com/):** Connected and authenticated to target GitHub organization.

---

## 🛠️ Created Resources

- **Azure: Entra ID - Service Principal (App Registration)**
  - Dedicated, privileged identity for executing changes in the Azure tenant. 
  - Uses federated credentials (OIDC) for authentication within GitHub Actions workflows. 
- **Azure: Remote Backend Resources**
  - Uses dedicated Azure subscription to contain remote states for all IaC projects. 
  - **Resource Group:** Created per deployment categories (platform, bootstrap, workloads). 
  - **Storage Account:** One account per deployment category (platform, bootstrap, workloads). 
  - **Containers:** Holds remote states per deployment stack (plz-governance, plz-management, etc). 
- **GitHub: Repository Environment, Secrets and Variables**
  - Creates repository environments per deployment stack. 
  - Adds Entra ID service principal details to repository secrets. 
  - Adds Azure resources used for remote backend per deployment stack environment. 

---

## ❓ Example Resource Structure

Resources are grouped by categories and their child stacks. 

- **Categories:** 
  - Bootstrap
  - Platform
- **Stacks:** 
  - Platform -> Governance (plz-governance)
  - Platform -> Connectivity (plz-connectivity)
  - Platform -> Management (plz-management)
  - Platform -> Identity (plz-identity)

```text
rg-org-iac-bootstrap
└── saorgiacbootstrap12345
    └── tfstate-iac-bootstrap

rg-org-iac-platform
└── saorgiacplatform12345
    ├── tfstate-plz-governance
    ├── tfstate-plz-connectivity
    ├── tfstate-plz-management
    └── tfstate-plz-identity
```

| Object                  | Created per  | Example                  | Purpose                                                   |
| ----------------------- | ------------ | ------------------------ | --------------------------------------------------------- |
| Resource Group          | **Category** | rg-org-plz-bootstrap     | Resource group containing components for bootstrapping.   |
| Resource Group          | **Category** | rg-org-plz-platform      | Resource group containing components for platform LZ.     |
| Storage Account         | **Category** | saorgplzbootstrap12345   | Holds blob container for bootstrapping deployment.        |
| Storage Account         | **Category** | saorgplzplatform12345    | Holds blob containers per platform deployment stack.      |
| Blob Container          | **Stack**    | tfstate-plz-governance   | Contains remote state file, referenced by stack workflow. |
| Blob Container          | **Stack**    | tfstate-plz-connectivity | Contains remote state file, referenced by stack workflow. |
| Blob Container          | **Stack**    | tfstate-plz-management   | Contains remote state file, referenced by stack workflow. |
| Blob Container          | **Stack**    | tfstate-plz-identity     | Contains remote state file, referenced by stack workflow. |
| Repository Environment  | **Stack**    | plz-governance           | Repository environment, contains stack related variables. |
| Repository Environment  | **Stack**    | plz-connectivity         | Repository environment, contains stack related variables. |
| Repository Environment  | **Stack**    | plz-management           | Repository environment, contains stack related variables. |
| Repository Environment  | **Stack**    | plz-identity             | Repository environment, contains stack related variables. |

---

## ▶️ Usage

### ➕ Create

1. Copy/rename Powershell data file `boostrap-example.psd1`. 
2. Replace example content with desired variable values. 
3. Execute the Powershell script and approve actions when prompted. 

```powershell
# Execute bootstrapping process. 
powershell -file deployments/bootstrap/bootstrap-azure-github.ps1 
```

4. Verify all resources have been deployed in Azure and GitHub. 
5. \[Optional\]: Migrate local state file to Azure when prompted. 

### ➖ Removal

**Note:** The PowerShell script will detect if an existing `backend.tf` file exists, and attempt to migrate state back to local. 

1. Execute the Powershell script using the `-Remove` parameter.  

```powershell
# Remove all bootstrap resources. 
powershell -file deployments/bootstrap/bootstrap-azure-github.ps1 -Remove
```

2. Remote backend is pulled from Azure locally and backed up. 
3. Approve removal of all created resources when prompted. 

---
