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
./scripts/bootstrap-azure-github/bootstrap-azure-github.ps1 -EnvFile "env.psd1"
./scripts/bootstrap-azure-github/bootstrap-azure-github.ps1 -EnvFile "env.psd1" -Destroy
#=======================================================#>

# SCRIPT VARIABLES =============================================#
# Command line input parameters.
param(
    [switch]$Destroy, # Add switch parameter for delete option.
    [Parameter(Mandatory = $true)][string]$EnvFile
)

# Required applications and validation commands.
$requiredApps = @(
    [PSCustomObject]@{ 
        Name        = "Azure CLI"; 
        Command     = "az"; 
        AuthCheck   = "az account show --only-show-errors | ConvertFrom-JSON"; 
        LoginCmd    = "az login --use-device-code";
        AccessCheck = 'az account subscription show --subscription-id $config.Azure.SubscriptionIAC -o json --only-show-errors | ConvertFrom-JSON'
    }
    [PSCustomObject]@{ 
        Name        = "GitHub CLI"; 
        Command     = "gh"; 
        AuthCheck   = "gh api user | ConvertFrom-JSON"; 
        LoginCmd    = "gh auth login";
        AccessCheck = '(gh api /repos/$($config.GitHub.Owner)/$($config.GitHub.Repo)/collaborators/$($ghSession.login)/permission | ConvertFrom-JSON)'
    }
)

# Terminal Colours.
$INF = "Green"
$WRN = "Yellow"
$ERR = "Red"
$HD1 = "Cyan"
$HD2 = "Magenta"

# Determine request action and populate hashtable for logging purposes.
if ($destroy) {
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
        if ($config.azure.naming.prefix) {
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
Write-Host "- Default Location: $($config.Azure.Location)"
Write-Host ""
Write-Host -ForegroundColor $HD1 "GitHub: " -NoNewLine; Write-Host -ForegroundColor Yellow "(User: $($ghSession.login))"
Write-Host "- Owner/Org: $(($ghSession.html_url).Replace('https://github.com/',''))"
Write-Host "- Repository: $($config.GitHub.Repo) [$($config.GitHub.Branch)]"
Write-Host "- Access: $(($test.PSObject.Properties | Where-Object {$_.Value -eq $true} | ForEach-Object {$_.Name}) -join ", ")"
Write-Host ""
Write-Host -ForegroundColor $HD1 "Deployment Action: " -NoNewLine; 
Write-Host -ForegroundColor $sys_action.colour "$($sys_action.do) $($sys_action.symbol)"
Write-Host -ForegroundColor $HD1 "Please ensure the above details are correct before proceeding."
Write-Host ""
if (!(Get-UserConfirm -prompt "Do you wish to proceed with 'Terraform Plan' stage [Y/N]?")) {
    Write-Host -ForegroundColor $WRN "[!] WARNING: User declined to proceed. Exit."
    exit 1
}

#================================================#
# MAIN: Stage 3 - Prepare Terraform
#================================================#

# Generate TFVARS file.
$tfVARS = @"
# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are to be stored securely in GitHub Secrets or environment variables.

# Azure Settings.
location = "$($config.Azure.Location)" # Desired location for resources to be deployed in Azure.

# Naming Settings (used for resource names).
naming = {
  environment = "$($config.Azure.Naming.Environment)" # Environment for resources/project (dev, tst, prd).
  prefix = "$($config.Azure.Naming.Prefix)" # Short name of organization (abc).
  project = "$($config.Azure.Naming.Project)" # Project name for related resources (platform, webapp01).
  service = "$($config.Azure.Naming.Service)" # Service name used in the project (iac, mgt, sec, con, gov).
}

# Tags (assigned to bootstrap resources).
tags = {
  Environment = "$($config.Azure.Tags.Environment)" # dev, tst, prd, alz
  Project = "$($config.Azure.Tags.Project)" # Name of the project the resources are for.
  Owner = "$($config.Azure.Tags.Owner)" # Team responsible for the resources.
  Creator = "$($config.Azure.Tags.Creator)" # Person or process that created the bootstrap resources.
  Deployed = "$(Get-Date -f "yyyyMMdd.HHmmss")" # Timestamp for identifying deployment.
}

# GitHub Settings.
github_config = {
    owner = "$($config.GitHub.Owner)" # Taken from current Github CLI session. 
    repo = "$($config.GitHub.Repo)" # Replace with your new desired GitHub repository name. Must be unique within the organization and empty.
    branch = "$($config.GitHub.Branch)" # Replace with your preferred branch name.
}
"@

# Write out TFVARS file (only if not already exists,offer to overwrite existing).
if (-not (Test-Path -Path "$PSScriptRoot/terraform/bootstrap.tfvars") ) {
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
if (terraform -chdir="$PSScriptRoot/terraform" init -upgrade) {
    Write-Host -ForegroundColor $INF "PASS"
}
else {
    Write-Host -ForegroundColor $ERR "FAIL" 
    Write-Host -ForegroundColor $ERR "[x] ERROR: Terraform initialization failed. Please check configuration and try again."
    exit 1
}

#===================================================#
# MAIN: Stage 4 - Execute Terraform (Deploy/Destroy)
#===================================================#

if (!($Destroy)) {
    # CREATE

    # Terraform: Plan
    Write-Host ""
    Write-Host -ForegroundColor $HD1 "[*] Performing Action: Running Terraform plan... "
    if (terraform -chdir="$PSScriptRoot/terraform" plan --out=bootstrap.plan `
            -var-file="bootstrap.tfvars" `
            -var="subscription_id_iac=$($config.Azure.SubscriptionIAC)"
    ) {
        Write-Host -ForegroundColor $INF "PASS" 
        terraform -chdir="$PSScriptRoot/terraform" show bootstrap.plan
    }
    else {
        Write-Host -ForegroundColor $ERR "FAIL" 
        Write-Host -ForegroundColor $ERR "[x] ERROR: Terraform plan failed. Please check configuration and try again."
        exit 1
    }

    # # Terraform: Apply
    # if(Test-Path -Path "$workingDir/bootstrap.tfplan"){
    #     Write-Host ""
    #     Write-Log -Level "WRN" -Message "Terraform will now deploy resources. This may take several minutes to complete."
    #     if(-not (Get-UserConfirm) ){
    #         Write-Log -Level "ERR" -Message "User aborted process. Please confirm intended configuration and try again."
    #         exit 1
    #     }
    #     else{
    #         Write-Log -Level "SYS" -Message "Performing Action: Running Terraform apply... "
    #         if(terraform -chdir="$($workingDir)" apply bootstrap.tfplan){
    #             Write-Host "PASS" -ForegroundColor Green
    #         } else{
    #             Write-Host "FAIL" -ForegroundColor Red
    #             Write-Log -Level "ERR" -Message "- Terraform plan failed. Please check configuration and try again."
    #             exit 1
    #         }
    #     }
    # } else{
    #     Write-Log -Level "ERR" -Message "- Terraform plan file missing! Please check configuration and try again."
    #     exit 1  
    # }

}
else {
    # DESTROY

}
