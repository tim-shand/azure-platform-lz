# 👢 Bootstrap: Azure & GitHub Actions for Terraform IaC Management

## 🌟 Overview

This deployment automates the **initial bootstrapping** process of both Azure and GitHub, in preparation for executing platform landing zone deployment workflows. 

- Run-once, locally executed, creates bootstrap and deployment stack resources required to deploy this Azure platform landing zone. 
- Generates repository secrets and variables used by deployment stack workflows. 
- Automates the migration process of the local bootstrap state file to Azure (remote state). 

---

## 📝 Requirements

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

```text
# Single-Subscription Platform Landing Zone
Subscription 1: abc-iac-sub    # Used as dedicated IaC subscription. Pass into workflow by repository variable. 
Subscription 2: abc-platform   # General platform subscription. Used for all platform stacks in this example.

# OR

# Multi-Subscription Platform Landing Zone
Subscription 1: abc-iac-sub            # Used as dedicated IaC subscription. Pass into workflow by repository variable. 
Subscription 2: abc-platform-sub       # General platform subscription. Used for governance and identity stacks in this example.
Subscription 3: abc-platform-con-sub   # Connectivity subscription. Dedicated subscription for connectivity resources. 
Subscription 4: abc-platform-mgt-sub   # Management subscription. Dedicated subscription for management resources. 
```

Notice that both the `governance` and `identity` stack configurations below are using the **same value** for the `subscription_identifier` field.  
Using the same value of `platform-sub` will result in the same subscription ID being resolved and used for both stacks.  
The subscription ID is resolved when a data call is made using the value provided by the `display_name_contains` parameter.  
Using the name part value for the subscription helps to keep subscription IDs out of the code base. 

```hcl
data "azurerm_subscriptions" "platform" {
  for_each              = var.platform_stacks                 # Loop for each object in "platform_stacks". 
  display_name_contains = each.value.subscription_identifier  # Read in each "subscription_identifier" per stack iteration. 
}

platform_stacks = {
  "bootstrap" = {
    stack_name              = "iac-bootstrap"    # Name of stack directory and GitHub environment. 
    stack_category          = "global"           # Backend Category: platform, workload, global/bootstrap. 
    subscription_identifier = "iac-sub"          # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_env              = false              # Enable to create related environment in GitHub for stack (NOT required for bootstrap/global).  
  },
  "connectivity" = {
    stack_name              = "plz-connectivity" # STATIC: Name of stack directory and GitHub environment. 
    stack_category          = "platform"         # Backend Category: platform, workload, global.  
    subscription_identifier = "con-sub"          # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value.  
    create_env              = true               # Enable to create related environment in GitHub for stack.  
  },
  "governance" = {
    stack_name              = "plz-governance"   # STATIC: Name of stack directory and GitHub environment. 
    stack_category          = "platform"         # Backend Category: platform, workload, global. 
    subscription_identifier = "platform-sub"     # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value.
    create_env              = true               # Enable to create related environment in GitHub for stack.  
  },
  "management" = {
    stack_name              = "plz-management"   # STATIC: Name of stack directory and GitHub environment. 
    stack_category          = "platform"         # Backend Category: platform, workload, global.  
    subscription_identifier = "mgt-sub"          # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_env              = true               # Enable to create related environment in GitHub for stack.  
  },
  "identity" = {
    stack_name              = "plz-identity"     # STATIC: Name of stack directory and GitHub environment.  
    stack_category          = "platform"         # Backend Category: platform, workload, global. 
    subscription_identifier = "platform-sub"     # Subscription name part, resolved to ID in data call. Subscription name required to contain provided value. 
    create_env              = true               # Enable to create related environment in GitHub for stack.  
  }
}
```

---

## 🌱 Resources

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

- **Resource Groups:** Created per deployment category (global, platform, workloads) to group related child resources for easy management and separation of purpose.  
- **Storage Accounts:** Similar to Resource Groups, created per deployment category to hold the Blob Containers used by each deployment stack. 
- **Blob Containers:** Created per deployment stack (plz-governance, plz-management, etc) under each parent category Storage Account to hold the remote Terraform state files. 
- **Key Vault:** Stores IDs, names and other details for shared services (Hub VNet, Log Analytics Workspace etc) to be accessed by other stacks. 

### GitHub: Repository Environments, Secrets and Variables

- Creates individual environments within the defined repository, **per deployment stack**. 
- This enables separation of purpose/duties and allows deployments to execute independently. 
- **Secrets:** Entra ID Service Principal details added at the repository level (globals). 
- **Variables:** Azure remote backend resources, added per deployment stack for each environment. 
- This allows workflows to utilise the `environment` parameter to access environment specific variables, or override globals. 

---

## ❔ Example Structure

Resources are grouped by categories and their child stacks. 

- **Categories:** 
  - Global
  - Platform
  - Workloads
- **Stacks:** 
  - Platform -> Governance (plz-governance)
  - Platform -> Management (plz-management)
  - Platform -> Connectivity (plz-connectivity)
  - Platform -> Identity (plz-identity)

```text
org-global-iac-rg
└── orgglobaliacsa12345
    └── tfstate-iac-bootstrap

org-platform-iac-rg
└── orgplatformiacsa12345
    ├── tfstate-plz-governance
    ├── tfstate-plz-management
    ├── tfstate-plz-connectivity
    └── tfstate-plz-identity
```

| Object                  | Created Per  | Example Name             | Purpose                                                   |
| ----------------------- | ------------ | ------------------------ | --------------------------------------------------------- |
| Resource Group          | **Category** | org-global-iac-rg        | Resource group containing bootstrap and global resources. |
| Resource Group          | **Category** | org-platform-iac-rg      | Resource group containing components for platform LZ.     |
| Storage Account         | **Category** | orgglobaliacsa12345      | Holds blob container for bootstrap and global resources.  |
| Storage Account         | **Category** | orgplatformiacsa12345    | Holds blob containers per platform deployment stack.      |
| Blob Container          | **Stack**    | tfstate-plz-governance   | Contains remote state file, referenced by stack workflow. |
| Blob Container          | **Stack**    | tfstate-plz-management   | Contains remote state file, referenced by stack workflow. |
| Blob Container          | **Stack**    | tfstate-plz-connectivity | Contains remote state file, referenced by stack workflow. |
| Blob Container          | **Stack**    | tfstate-plz-identity     | Contains remote state file, referenced by stack workflow. |
| Repository Environment  | **Stack**    | plz-governance           | Repository environment, contains stack related variables. |
| Repository Environment  | **Stack**    | plz-management           | Repository environment, contains stack related variables. |
| Repository Environment  | **Stack**    | plz-connectivity         | Repository environment, contains stack related variables. |
| Repository Environment  | **Stack**    | plz-identity             | Repository environment, contains stack related variables. |

---

## ▶️ Usage

### Create/Deploy

```bash
# Manual execution of Terraform
terraform -chdir="./bootstrap" init
terraform -chdir="./bootstrap" validate
terraform -chdir="./bootstrap" plan -var-file="../variables/global.tfvars" -var-file="../variables/iac-bootstrap.tfvars"
terraform -chdir="./bootstrap" apply -var-file="../variables/global.tfvars" -var-file="../variables/iac-bootstrap.tfvars"
```

### Remove/Destroy

```bash
# Manual execution of Terraform
terraform -chdir="./bootstrap" destroy -var-file="../variables/global.tfvars" -var-file="../variables/iac-bootstrap.tfvars"
```

---
