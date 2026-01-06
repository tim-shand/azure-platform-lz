<#======= Bootstrap: Azure & GitHub for Terraform =======#
# REQUIRED:
- Populate "env.psd1" file with required values. 
- Install: Azure CLI, GitHub CLI.
- Existing Azure subscription dedicated to IaC purposes (or platform general).
- Existing GitHub repository for project secrets and variables. 

# DESCRIPTION:
Bootstrap script to prepare Azure tenant for management via Terraform and GitHub Actions.
- Checks for required local applications (see variable `$requiredApps`).
- Confirms required user-defined variables have been set.
- Validates Azure CLI authentication, obtains Azure tenant information from current session.
- Validates Github CLI authentication, confirms access to provided target repository.
- Azure:
  - Creates Service Principal (App Registration) in Entra ID to be used for IaC.
  - Adds federated credentials (OIDC) for GitHub repository/branch to the Service Principal.
  - Assigns RBAC roles to Service Principal for managing tenant root group.
  - Set current user and Service Principal to the "owner" of the Service Principal.
  - Assign Microsoft Graph API permissions to allow self-updating of federated credentials for IaC backend vending.
  - Create IaC backend resources: Resource Group, Storage Account, Blob Container. 
- GitHub:
  - Add Azure tenant and subscription details as repository secrets. 
  - Add created Azure resource details for IaC backend as repository variables.

# USAGE:
./scripts/bootstrap-azure-github/bootstrap-azure-github.ps1 -EnvFile "env.psd1" -Action Create/Remove
#=======================================================#>

# SCRIPT VARIABLES =============================================#
# Command line input parameters.
param(
    #[switch]$Action = , # Add switch parameter for delete option.
    [Parameter(Mandatory = $true)][string]$EnvFile,
    [Parameter(Mandatory = $true)][ValidateSet("Create", "Remove")][string]$Action
)

# Required applications and validation commands.
$requiredApps = @(
    [PSCustomObject]@{ 
        Name        = "Azure CLI"; 
        Command     = "az"; 
        AuthCheck   = "az account show --only-show-errors | ConvertFrom-JSON"; 
        LoginCmd    = "az login --use-device-code";
        AccessCheck = 'az account subscription show --subscription-id $config.global.subscription_iac_bootstrap -o json --only-show-errors | ConvertFrom-JSON'
    }
    [PSCustomObject]@{ 
        Name        = "GitHub CLI"; 
        Command     = "gh"; 
        AuthCheck   = "gh api user | ConvertFrom-JSON"; 
        LoginCmd    = "gh auth login";
        AccessCheck = '(gh api /repos/$($config.repo_config.Owner)/$($config.repo_config.Repo)/collaborators/$($config.repo_config.Owner)/permission | ConvertFrom-JSON).user.permissions'
    }
)
# Set direcotry for Terraform files.
$tfDir = "$PSScriptRoot/terraform"

# Terminal Colours.
$INF = "Green"
$WRN = "Yellow"
$ERR = "Red"
$HD1 = "Cyan"
$HD2 = "Magenta"

# Determine request action and populate hashtable for logging purposes.
if ($Action -eq "Remove") {
    $sys_action = @{
        do      = "Remove"
        past    = "Removed"
        current = "Removing"
        colour  = "Magenta"
        symbol  = "[-]"
    }
}
else {
    $sys_action = @{
        do      = "Create"
        past    = "Created"
        current = "Creating"
        colour  = "Green"
        symbol  = "[+]"
    }
}

# FUNCTIONS ========================================#
function Get-UserConfirm ($prompt) {
    while ($true) {
        $userConfirm = (Read-Host -Prompt $prompt)
        switch -Regex ($userConfirm.Trim().ToLower()) {
            "^(y|yes)$" {
                return $true
            }
            "^(n|no)$" {
                return $false
            }
            default {
                Write-Host -ForegroundColor $WRN "[!] Invalid response. Please enter [Y/Yes/N/No]."
            }
        }
    }
}

#=============================================#
# MAIN: Stage 1 - Validations & Pre-Checks
#=============================================#
Clear-Host
Write-Host -ForegroundColor $HD1 "======================================================"
Write-Host -ForegroundColor $HD2 "     Bootstrap Script: Azure | Github | Terraform     "
Write-Host -ForegroundColor $HD1 "======================================================`r`n"

# Validation: Provided variables file. Check path exists and values can be queried. 
$env_file = Join-Path -Path $PSScriptRoot -ChildPath $EnvFile
Write-Host -ForegroundColor $HD1 -NoNewLine "[*] Validating provided variables file... "
if (!(Test-Path -Path $env_file)) {
    Write-Host -ForegroundColor $ERR "FAIL"
    Write-Host -ForegroundColor $ERR "[x] ERROR: Required variables file not found! Please create it and try again."
    exit 1
}
else {
    Try {
        # Import variables from file into '$config' variable.
        $config = Import-PowerShellDataFile -Path $env_file
        if ($config.naming.prefix) {
            Write-Host -ForegroundColor $INF "PASS"
        }
        else {
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $ERR "[x] ERROR: Provided variable formatting is invalid. Please check and try again."
            exit 1
        }
    }
    Catch {
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] ERROR: Failed to load variables file! $_"
        exit 1
    }
}

# Validation: Required Applications and Authentication.
ForEach ($app in $requiredApps) {
    Write-Host -ForegroundColor $HD1 -NoNewLine "[*] Checking application '$($app.name)'... "
    # Check if application is install by executing its primary command.
    if (!(Get-Command $app.Command -ErrorAction SilentlyContinue 2>&1)) {
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] ERROR: Required application '$($app.name)' is missing. Please install it and try again."
        exit 1
    }
    else {
        # Check is application is authenticated. If not, prompt to authenticate.
        if (!(Invoke-Expression $app.AuthCheck -ErrorAction SilentlyContinue 2>&1)) {
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $WRN "[!] WARNING: Required application '$($app.name)' is not authenticated!"
            if (Get-UserConfirm -prompt "Do you wish to proceed with login [Y/N]?") {
                Invoke-Expression $app.LoginCmd
            }
            else {
                Write-Host -ForegroundColor $WRN "[!] WARNING: User declined to proceed with authentication. Exit."
                exit 1
            }
        }
        # Test access to resources.
        if (!(Invoke-Expression $app.AccessCheck -ErrorAction SilentlyContinue 2>&1)) {
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $ERR "[x] ERROR: Failed access check for application '$($app.name)'. Please check environment permissions and try again."
            exit 1
        }
        else {
            Write-Host -ForegroundColor $INF "PASS"
        }
    }
    # Get current authenticated application session into dynamic variables (azSession, ghSession).
    New-Variable -Name "$($app.Command)Session" -Value (Invoke-Expression $app.AuthCheck -ErrorAction SilentlyContinue) -Force
    New-Variable -Name "$($app.Command)Access" -Value (Invoke-Expression $app.AccessCheck -ErrorAction SilentlyContinue) -Force
}

#================================================#
# MAIN: Stage 2 - Display Config / Actions
#================================================#

Invoke-Expression "az config set extension.use_dynamic_install=yes_without_prompt --only-show-errors" >$null 2>&1
Write-Host ""
Write-Host -ForegroundColor $HD1 "Azure: " -NoNewLine; Write-Host -ForegroundColor Yellow "(User: $($azSession.user.name))"
Write-Host "- Tenant ID: $($azSession.tenantId)"
Write-Host "- Tenant Name: $($azSession.tenantDisplayName)"
Write-Host "- Subscription ID: $($azAccess.subscriptionId)"
Write-Host "- Subscription Name: $($azAccess.displayName)"
Write-Host "- Default Location: $($config.global.location)"
Write-Host ""
Write-Host -ForegroundColor $HD1 "Repository: " -NoNewLine; Write-Host -ForegroundColor Yellow "(User: $($ghSession.login))"
Write-Host "- Owner/Org: $(($ghSession.html_url).Replace('https://github.com/',''))"
Write-Host "- Repository: $($config.repo_config.repo) [$($config.repo_config.Branch)]"
Write-Host "- Access: $(($ghAccess.PSObject.Properties | Where-Object {$_.Value -eq $true} | ForEach-Object {$_.Name}) -join ", ")"
Write-Host ""
Write-Host -ForegroundColor $HD1 "Deployment Action: " -NoNewLine; 
Write-Host -ForegroundColor $sys_action.colour "$($sys_action.do) $($sys_action.symbol)"
Write-Host -ForegroundColor $HD1 "Please ensure the above details are correct before proceeding."
Write-Host ""
if (!(Get-UserConfirm -prompt "Do you wish to proceed [Y/N]?")) {
    Write-Host -ForegroundColor $WRN "[!] WARNING: User declined to proceed. Exit."
    exit 1
}

#================================================#
# MAIN: Stage 3 - Prepare Terraform
#================================================#

# Generate TFVARS file.
$tfVARS = @"
# !! DO NOT COMMIT !! - If using public repository or including sensitive values.
# General: Azure and GitHub Configuration ---------------------------------|
global = {
  location    = "$($config.global.location)" # Default preferred location for IaC backend resources. 
}
naming = {
  prefix      = "$($config.naming.prefix)"  # Short name of organization ("abc"). Used in resource naming.
  project     = "$($config.naming.project)" # Project name for related resources (platform, webapp01). 
  service     = "$($config.naming.service)" # Service name used in the project (gov, con, sec, mgt, wrk). 
  environment = "$($config.naming.environment)" # Environment for resources/project (dev, tst, prd, sys).
}
tags = {
  Environment = "$($config.tags.Environment)" # dev, tst, prd. 
  Project     = "$($config.tags.Project)" # Name of the project. 
  Owner       = "$($config.tags.Owner)" # Team responsible for the resources. 
  Creator     = "$($config.tags.Creator)" # Person or process that created the initial resources. 
}
repo_config = {
  owner  = "$($config.repo_config.owner)" # Org/owner, target repository, and branch name.
  repo   = "$($config.repo_config.repo)"
  branch = "$($config.repo_config.branch)"
}

# Stacks: Configuration ---------------------------------|
deployment_stacks = {
  bootstrap = {
      bootstrap = {
      stack_name        = "iac-bootstrap"
      subscription_id   = "$($config.global.subscription_iac_bootstrap)"
      create_repo_env = false # No need for separate bootstrap environment in GitHub. 
    }
  }
  platform = {
    connectivity = {
      stack_name        = "plz-connectivity"
      subscription_id   = "$($config.global.subscription_plz_connectivity)"
      create_repo_env = true
    }
    governance = {
      stack_name        = "plz-governance"
      subscription_id   = "$($config.global.subscription_plz_governance)"
      create_repo_env = true
    }
    management = {
      stack_name        = "plz-management"
      subscription_id   = "$($config.global.subscription_plz_management)"
      create_repo_env = true
    }
    identity = {
      stack_name        = "plz-identity"
      subscription_id   = "$($config.global.subscription_plz_identity)"
      create_repo_env = true
    }
  }
  workloads = {
    # Placeholder to ensure resource group and storage account structure is created. 
    # To be used in future for workload IaC Backend Vending. 
  }
}
"@

# Write out TFVARS file (only if not already exists,offer to overwrite existing).
if (! (Test-Path -Path "$PSScriptRoot/terraform/bootstrap.tfvars") ) {
    $tfVARS | Out-File -Encoding utf8 -FilePath "$PSScriptRoot/terraform/bootstrap.tfvars" -Force
}
else {
    Write-Host ""
    Write-Host -ForegroundColor $WRN "[!] WARNING: An existing TFVARS file is present."
    if (Get-UserConfirm -prompt "Do you wish to replace the existing file (Y) or keep original (N) [Y/N]?") {
        $tfVARS | Out-File -Encoding utf8 -FilePath "$PSScriptRoot/terraform/bootstrap.tfvars" -Force
    }
}

# Terraform: Initialize
Write-Host ""
Write-Host -ForegroundColor $HD1 "[*] Performing Action: Initialize Terraform configuration... " -NoNewLine
if (terraform -chdir="$($tfDir)" init -upgrade) {
    Write-Host -ForegroundColor $INF "PASS"
}
else {
    Write-Host -ForegroundColor $ERR "FAIL" 
    Write-Host -ForegroundColor $ERR "[x] ERROR: Terraform initialization failed. Please check configuration and try again."
    exit 1
}

#===================================================#
# MAIN: Stage 4 - Execute Terraform (Deploy/Remove)
#===================================================#

if ($Action -eq "Remove") {
    # Check for local file (download from remote storage and place in Terraform directory).
    Write-Host -ForegroundColor $HD1 "[*] Checking for local state file... " -NoNewline
    if (Test-Path -Path "$tfDir/*.tfstate") {
        Rename-Item -Path "$tfDir/*.tfstate" -NewName "$tfDir/terraform.tfstate"
        Write-Host -ForegroundColor $INF "PASS"
        terraform -chdir="$($tfDir)" destroy -var-file="bootstrap.tfvars"
    }
    else {
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] Local state file is missing. Please download from remote storage and try again." 
    }
}
else {
    # Terraform: Plan
    Write-Host ""
    Write-Host -ForegroundColor $HD1 "[*] Performing Action: Running Terraform plan... " -NoNewLine
    if (terraform -chdir="$($tfDir)" plan --out=bootstrap.plan `
            -var-file="bootstrap.tfvars"
    ) {
        Write-Host -ForegroundColor $INF "PASS" 
        terraform -chdir="$($tfDir)" show bootstrap.plan
    }
    else {
        Write-Host -ForegroundColor $ERR "FAIL" 
        Write-Host -ForegroundColor $ERR "[x] ERROR: Terraform plan failed. Please check configuration and try again."
        exit 1
    }
    
    # Terraform: Apply
    Write-Host ""
    if (Test-Path -Path "$PSScriptRoot/terraform/bootstrap.plan") {
        Write-Host -ForegroundColor $WRN "[!] Terraform will now deploy changes. This may take several minutes to complete."
        if (!(Get-UserConfirm -prompt "Do you wish to proceed [Y/N]?") ) {
            Write-Host -ForegroundColor $ERR "[x] ERROR: User aborted process. Please confirm intended configuration and try again."
            exit 1
        }
        else {
            Write-Host -ForegroundColor $HD1 "[*] Performing Action: Running Terraform apply... "
            Try {
                terraform -chdir="$($tfDir)" apply bootstrap.plan
            }
            Catch {
                Write-Host "FAIL" -ForegroundColor $ERR
                Write-Host -ForegroundColor $ERR "[x] Terraform plan failed. Please check configuration and try again. $_"
                exit 1
            }
        }
    }
    else {
        Write-Host -ForegroundColor $ERR "[x] Terraform plan file missing! Please check configuration and try again."
        exit 1  
    }
}

#================================================#
# MAIN: Stage 5 - Migrate State to Azure
#================================================#

if (!($Action -eq "Remove")) {
    # Get Github variables from Terraform output.
    Write-Host -ForegroundColor $HD1 "[*] Retrieving Terraform backend details from output... " -NoNewLine
    Try {
        $tf_rg = terraform -chdir="$($tfDir)" output -raw bootstrap_iac_rg
        $tf_sa = terraform -chdir="$($tfDir)" output -raw bootstrap_iac_sa
        $tf_cn = terraform -chdir="$($tfDir)" output -raw bootstrap_iac_cn
        Write-Host -ForegroundColor $INF "PASS"
        Write-Host ""
        Write-Host "- Resource Group: $tf_rg"
        Write-Host "- Storage Account: $tf_sa"
        Write-Host "- Blob Continer: $tf_cn"
    }
    Catch {
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] Failed to get Terraform output values. Please check configuration and try again."
        exit 1
    }

    # Generate backend config for state migration.
    $tfBackend = `
        @"
terraform {
  backend "azurerm" {
    resource_group_name  = "$($tf_rg)"
    storage_account_name = "$($tf_sa)"
    container_name       = "$($tf_cn)"
    key                  = "azure-iac-bootstrap.tfstate"
    use_azuread_auth     = true # Enable for Entra ID only authentication.
  }
}
"@
    $tfBackend | Out-File -Encoding utf8 -FilePath "$PSScriptRoot/terraform/backend.tf" -Force

    # Terraform: Migrate State
    Write-Host -ForegroundColor $WRN "[!] Terraform will now migrate state to Azure... "
    if (Get-UserConfirm -prompt "Do you wish to proceed [Y/N]?") {
        Write-Host ""
        Write-Host -ForegroundColor $HD1 "[*] Migrating Terraform state to Azure... " -NoNewline
        if (terraform -chdir="$($tfDir)" init -migrate-state -force-copy -input=false) {
            Write-Host -ForegroundColor $INF "PASS"
            #Remove-Item -Path "$PSScriptRoot/terraform/*.tfstate*" -Force -ErrorAction SilentlyContinue
        }
        else {
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $ERR "[x] Failed to migrate Terraform state to Azure. Please check configuration and try again."
        }
    }
    else {
        Write-Host -ForegroundColor $WRN "[!] Terraform state migration aborted by user."
        Remove-Item -Path "$PSScriptRoot/terraform/backend.tf" -Force -ErrorAction SilentlyContinue
    }
}

#================================================#
# MAIN: Stage 6 - Clean Up
#================================================#
#Remove-Item -Path "$PSScriptRoot/terraform/bootstrap.tfvars" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$PSScriptRoot/terraform/bootstrap.plan" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$PSScriptRoot/terraform/.terraform*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$PSScriptRoot/terraform/.terraform.*" -Force -ErrorAction SilentlyContinue
Write-Host ""
if ($Action -ne "Remove") {
    Write-Host -ForegroundColor $WRN "NOTE: Manual approval may be required for pending API permissions assigned to the Service Principal."
}
Write-Host ""
Write-Host -ForegroundColor $HD1 "===== BOOTSTRAP SCRIPT COMPLETE ====="
Write-Host ""
