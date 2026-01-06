# Bootstrap: Azure & GitHub Actions for Terraform IaC Management

_Run-once Powershell/Terraform deployment to bootstrap Azure and GitHub for IaC and CI/CD management._

This bootstrap deployment will create resources in both Azure and GitHub, required for future deployments using Github Actions workflows, allowing for centralized storage of workload and platform project state files. All project state files can be managed from a single IaC subscription.

- Designed for use with multiple deployment stacks to deploy an Azure platform landing zone. 
- Automates initial bootstrapping process using combination of Powershell and Terraform executed locally. 
- Automates the bootstrap state migration post-setup, from local to newly created Azure resources. 

---

## :green_book: Requirements

### Accounts

- **Azure:** Existing Azure account with required roles assigned to a _dedicated_ subscription for IaC.
  - **Roles:** `Contributor`, `Storage Blob Data Contributor`, `User Access Administrator`. 
- **GitHub:** Existing GitHub account with a repository for the Azure project.

### Required Applications (Installed & Authenticated Locally)

- **[Terraform](https://developer.hashicorp.com/terraform/install):** Used to deploy resources to target Azure environment.
- **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest):** Required by Terraform `AzureRM` provider to connect to Azure.
- **[GitHub CLI](https://cli.github.com/):** Connected and authenticated to target GitHub organization.

---

## :hammer_and_wrench: Created Resources

- **Entra ID: Service Principal (App Registration)**
  - Dedicated, privileged identity for executing changes in the Azure tenant. 
  - Uses federated credentials (OIDC) for authentication with GitHub Actions workflows. 
- **GitHub: Repository Environment, Secrets and Variables**
  - Adds Entra ID service principal details to repository secrets. 
  - Adds Azure resources used for remote backend storage to GitHub Actions variables per stack environment. 
- **Azure: Remote Backend Resources**
  - Uses dedicated Azure subscription to contain remote states for all IaC projects. 
  - **Resource Group:** Logical container for deployment categories (platform, bootstrap, workloads). 
  - **Storage Account:** Holds all storage containers in one account per deployment category (platform, bootstrap, workloads). 
  - **Containers:** Logical grouping of remote states per deployment stack (plz-governance, plz-management etc). 

---

## :arrow_forward: Usage

### Create

1. Copy/rename Powershell data file `env-example.psd1`.
2. Populate with required variable values.
3. Execute the Powershell script using the desired action parameter, including the name of the `env` file.

```powershell
# Execute bootstrapping process. 
powershell -file utilities/bootstrap-azure-github/bootstrap-azure-github.ps1 -EnvFile env.psd1 -Action Create
```

4. Verify all resources have been deployed in Azure and GitHub.
5. \[Optional\]: Migrate local state file to Azure when prompted.

### Remove

1. Download the remote state file from Azure and place in `utilities/bootstrap-azure-github/terraform` directory. 
2. Execute Powershell script using the `-Action Remove` parameter. 
3. Approve removal of all created resources when prompted. 

```powershell
# Remove bootstrap resources. 
powershell -file utilities/bootstrap-azure-github/bootstrap-azure-github.ps1 -EnvFile env.psd1 -Action Remove
```
