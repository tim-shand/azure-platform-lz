# Bootstrap: Azure & GitHub Actions for Terraform IaC Management

## Overview

This deployment automates the **initial bootstrapping** process of both Azure and GitHub, in preparation for executing platform landing zone deployment workflows. 

- Run-once, locally executed, creates bootstrap and deployment stack resources required to deploy this Azure platform landing zone. 
- Generates repository secrets and variables used by deployment stack workflows. 
- Automates the migration process of the local bootstrap state file to Azure (remote state). 

---

## Requirements

### Accounts/Platforms

- **Azure:** Existing Azure account with required roles assigned to a _dedicated_ IaC subscription. 
  - **Roles:** `Contributor`, `User Access Administrator`, `[optional] Global Admin`. 
- **GitHub:** GitHub account with a existing repository for the Azure platform landing zone project. 
  - **Roles:** Read/Write access to `actions`, `actions variables`, `administration`, `code`, `environments`, and `secrets`. 

### Applications (Installed & Authenticated Locally)

- **[Terraform](https://developer.hashicorp.com/terraform/install):** IaC tool used to deploy resources into the target Azure and GitHub tenancies. 
- **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest):** CLI tool required by Terraform provider (`AzureRM`) to connect to Azure. 
- **[GitHub CLI](https://cli.github.com/):** CLI tool used to interact with GitHub, connected and authenticated to the target GitHub organisation.

### Subscriptions

This design is intended to be provided with a **dedicated IaC subscription**, containing and isolating all backend resources from workload subscriptions. 
Using this method help to reduce blast radius in the event unwanted subscription changes are made that could negatively affect backend resources. 

#### Purpose & Usage

- This bootstrap deployment requires at least **one** existing subscription to be used as the **IaC**, or Infrastructure-as-Code subscription. 
- This means the subscription provided will be used to contain the backend resources for all the platform landing zone deployment stacks. 
- Separate subscriptions can be used for each of the deployment stacks if required; however, re-using the same subscription is also acceptable. 

#### Naming Method

- Subscriptions should be named in a way that makes them uniquely identifiable. 
- Using this method enables the subscription IDs to be resolved by a Terraform data call, using a __keyword-based__ lookup method. 
- This ensures subscription IDs are **not stored in variable files**. 

**Example:**  

Notice that both `governance` and `identity` stack configurations below are using the **same value** for the `subscription_identifier` field.  
The same subscription ID will be resolved by a data call using the value in the `display_name_contains` parameter. 

```hcl
data "azurerm_subscriptions" "platform" {
  for_each              = var.platform_stacks                 # Loop for each object in "platform_stacks". 
  display_name_contains = each.value.subscription_identifier  # Read in each "subscription_identifier" per stack iteration. 
}

platform_stacks = {
  "connectivity" = {
    stack_name              = "plz-connectivity" # STATIC: Name of stack directory and GitHub environment. 
    stack_category          = "platform"         # Backend Category: platform, workload, bootstrap. 
    subscription_identifier = "sub-con"          # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value.  
  },
  "governance" = {
    stack_name              = "plz-governance" # STATIC: Name of stack directory and GitHub environment. 
    stack_category          = "platform"       # Backend Category: platform, workload, bootstrap.
    subscription_identifier = "platform"       # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value.
  },
  "management" = {
    stack_name              = "plz-management" # STATIC: Name of stack directory and GitHub environment. 
    stack_category          = "platform"       # Backend Category: platform, workload, bootstrap. 
    subscription_identifier = "sub-management" # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
  },
  "identity" = {
    stack_name              = "plz-identity" # STATIC: Name of stack directory and GitHub environment.  
    stack_category          = "platform"     # Backend Category: platform, workload, bootstrap.
    subscription_identifier = "platform"     # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
  }
}
```

---

## Resources

### Azure: Service Principal

- A dedicated identity (App Registration + Service Principal) used to authenticate with Entra ID. 
- Executes deployments against the tenant from within automation workflows. 
- Uses [OpenID Connect (OIDC)](https://learn.microsoft.com/en-us/entra/identity-platform/v2-protocols-oidc) for secure authentication, **avoiding** the need for managing client secrets or certificate based authentication. 

### Azure: Management Group

- A top-level "core" Management Group is created under the default tenant root group. 
- This "core" Management Group represents the organisation in the current hierarchy, while accommodating for future changes or migration in the future. 
- All existing subscriptions accessible by the user running the bootstrap, will be **moved** under this new Management Group. 
- **RBAC** roles assigned at the "core" Management Group level are then inherited by child subscriptions. 
- This allows the Service Principal to provision resources, make further changes to Management Group structure, and perform subscription assignments. 

### Azure: Remote Backend Resources

- **Resource Groups:** Created per deployment category (bootstrap, platform, workloads) to group related child resources for easy management and separation of purpose.  
- **Storage Accounts:** Similar to Resource Groups, created per deployment category to hold the Blob Containers used by each deployment stack. 
- **Blob Containers:** Created per deployment stack (plz-governance, plz-management, etc) under each parent category Storage Account to hold the remote Terraform state files. 

### GitHub: Repository Environments, Secrets and Variables

- Creates individual environments within the defined repository, **per deployment stack**. 
- This enables separation of purpose/duties and allows deployments to execute independently. 
- **Secrets:** Entra ID Service Principal details added at the repository level (globals). 
- **Variables:** Azure remote backend resources, added per deployment stack for each environment. 
- This allows workflows to utilise the `environment` parameter to access environment specific variables, or override globals. 

---

## Example Structure

Resources are grouped by categories and their child stacks. 

- **Categories:** 
  - Bootstrap
  - Platform
  - Workloads
- **Stacks:** 
  - Platform -> Governance (plz-governance)
  - Platform -> Management (plz-management)
  - Platform -> Connectivity (plz-connectivity)
  - Platform -> Identity (plz-identity)

```text
org-iac-bootstrap-rg
└── orgiacbootstrapsa12345
    └── tfstate-iac-bootstrap

org-iac-platform-rg
└── orgiacplatformsa12345
    ├── tfstate-plz-governance
    ├── tfstate-plz-management
    ├── tfstate-plz-connectivity
    └── tfstate-plz-identity
```

| Object                  | Created Per  | Example Name             | Purpose                                                   |
| ----------------------- | ------------ | ------------------------ | --------------------------------------------------------- |
| Resource Group          | **Category** | org-plz-bootstrap-rg     | Resource group containing components for bootstrapping.   |
| Resource Group          | **Category** | org-plz-platform-rg      | Resource group containing components for platform LZ.     |
| Storage Account         | **Category** | orgplzbootstrapsa12345   | Holds blob container for bootstrapping deployment.        |
| Storage Account         | **Category** | orgplzplatformsa12345    | Holds blob containers per platform deployment stack.      |
| Blob Container          | **Stack**    | tfstate-plz-governance   | Contains remote state file, referenced by stack workflow. |
| Blob Container          | **Stack**    | tfstate-plz-management   | Contains remote state file, referenced by stack workflow. |
| Blob Container          | **Stack**    | tfstate-plz-connectivity | Contains remote state file, referenced by stack workflow. |
| Blob Container          | **Stack**    | tfstate-plz-identity     | Contains remote state file, referenced by stack workflow. |
| Repository Environment  | **Stack**    | plz-governance           | Repository environment, contains stack related variables. |
| Repository Environment  | **Stack**    | plz-management           | Repository environment, contains stack related variables. |
| Repository Environment  | **Stack**    | plz-connectivity         | Repository environment, contains stack related variables. |
| Repository Environment  | **Stack**    | plz-identity             | Repository environment, contains stack related variables. |

---

## Usage

### Create/Deploy

```bash
# Manual execution of Terraform
terraform -chdir="./bootstrap" init
terraform -chdir="./bootstrap" validate
terraform -chdir="./bootstrap" plan -var-file="../variables/global.tfvars" -var-file="../variables/iac-bootstrap.tfvars"
terraform -chdir="./bootstrap" apply -var-file="../variables/global.tfvars" -var-file="../variables/iac-bootstrap.tfvars"
```

