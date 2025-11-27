# Bootstrap: Azure & GitHub Actions for Terraform IaC Management

_Run-once Powershell/Terraform deployment to bootstrap Azure and GitHub platforms for IaC and CI/CD management._

This bootstrap deployment will create resources in both Azure and GitHub, required for future deployments using Github Actions workflows, allowing for centralized storage of workload and platform project state files.

This can be helpful when utilizing a monolithic style repository, as all project state files can be managed from the one location.

## :green_book: Requirements

### Accounts

- **Azure:** Existing Azure account with `contributor` role assigned to a _dedicated_ subscription for IaC.
- **Github:** Existing Github account with a repository for the Azure project.

### Required Applications (Installed & Authenticated Locally)

- **[Terraform](https://developer.hashicorp.com/terraform/install):** Used to deploy resources to target Azure environment.
- **[Azure CLI](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest):** Required by Terraform `AzureRM` provider to connect to Azure.
- **[Github CLI](https://cli.github.com/):** Connected and authenticated to target Github organization.

## :hammer_and_wrench: Created Resources

- **Entra ID: Service Principal (App Registration)**
  - Dedicated, privileged identity for executing changes in the Azure tenant.
  - Uses federated credentials (OIDC) for authentication with GitHub Actions workflows.
- **GitHub: Repository Secrets and Variables**
  - Adds Entra ID service principal details to repository secrets.
  - Added AZure resources used for remote backend storage to GitHub Actions variables.
- **Azure: Remote Backend Resources**
  - Uses dedicated Azure subscription to contain remote states for all IaC projects.
  - **Resource Group:** Logical container for IaC related resources.
  - **Storage Account:** Holds all storage containers in one account.
  - **Containers:** Logical grouping of remote states per IaC project.

## :arrow_forward: Usage

### Create

1. Copy/rename Powershell data file `env-example.psd1`.
2. Populate with required variable values.
3. Execute the Powershell script using the desired action parameter, including the name of the `env` file.

```powershell
# Create
powershell -file ./scripts/bootstrap-azure-github/bootstrap-azure-github.ps1 -EnvFile "env.psd1" -Action Create
```

4. Verify all resources have been deployed in Azure and GitHub.
5. \[Optional\]: Migrate local state file to Azure when prompted.

### Remove

1. Download the remote state file from Azure and place in `bootstrap/terraform` directory.
2. Execute Powershell script using the `-Action Remove` parameter.
3. Approve removal of all created resources when prompted.

```powershell
# Remove
powershell -file ./scripts/bootstrap-azure-github/bootstrap-azure-github.ps1 -EnvFile "env.psd1" -Action Remove
```

---
