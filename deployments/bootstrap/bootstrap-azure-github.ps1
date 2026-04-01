<#======= Bootstrap: Azure & GitHub for Terraform =======#
# DESCRIPTION:
Bootstrap script to prepare Azure tenant and GitHub repository for platform landing zone.
- Checks for required local applications (see variable `$requiredApps`).
- Validates Azure and GitHub CLI authentication, obtains information from current sessions.
- Deploys Azure and GitHub resources required for bootstrapping environments. 

# ACTIONS:
- Check for required CLI applications.
- Confirm authentication to Azure and GitHub, get current session details.
- Create Azure resources:
  - App Registration + Service Principal.
  - Federated (OIDC) credentials for GitHub repository and `main` branch, with environments.
  - Custom role and RBAC assignments at tenant scope.
  - Resource Group, Storage Account, Blob Container per deployment stack.
- Create GitHub resources:
  - Separate per-stack GitHub repository environments.
  - Secrets and variables (outputs from Azure resources).

# REQUIREMENTS:
- `Global Administrator` role assigned to user executing script.
- Applications installed: Azure CLI, GitHub CLI.
- Existing Azure subscription dedicated to IaC purposes (or use platform subscription).
- Existing GitHub repository for project secrets and variables.

# USAGE:
./bootstrap/bootstrap-azure-github.ps1
./bootstrap/bootstrap-azure-github.ps1 -Remove
#=======================================================#>

# SCRIPT VARIABLES =============================================#
# Command line input parameters.
param(
    [switch]$Remove # Add switch parameter for removal option.
)

# Terminal Colours.
$PASS = "Green"
$WRN = "Yellow"
$ERR = "Red"
$HD1 = "Cyan"
$HD2 = "Magenta"

# Required applications and validation commands.
$requiredApps = @(
    [PSCustomObject]@{Name = "Azure CLI"; Command = "az"; AuthCheck = "az account show --only-show-errors | ConvertFrom-JSON"; AuthLogin = "az login" }
    [PSCustomObject]@{Name = "GitHub CLI"; Command = "gh"; AuthCheck = "gh api user | ConvertFrom-JSON"; AuthLogin = "gh auth login" }
    [PSCustomObject]@{Name = "Terraform"; Command = "terraform"; AuthCheck = "BYPASS"; }
)

# Directories, Files and Misc.
$dir_tf = "$PSScriptRoot/terraform" # Location of Terraform files. 
$dir_ps_vars = "$PSScriptRoot/../../variables" # Location of Terraform variable files (in relation project root).
$var_files = @("global.tfvars", "iac-bootstrap.tfvars.json") # Array of required variable files for bootstrap process. 

# Set action attributes. 
if ($Remove) {
    $sys_action = @{
        name   = "Remove"
        colour = "Magenta"
        symbol = "-"
    }
}
else {
    $sys_action = @{
        name   = "Deploy"
        colour = "Green"
        symbol = "+"
    }
}

# FUNCTIONS ========================================#
# Function: Prompt user to confirm action. 
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

# Function: Get repository details from 'global.tfvars' file.
function Get-RepoConfig {
    param([string]$FilePath)
    $lines = (Get-Content -Raw $FilePath) -split "`n" | ForEach-Object { $_.Trim() }
    $inRepoConfig = $false
    $repoConfig = @{}
    foreach ($line in $lines) {
        # Detect start of repo_config block. 
        if ($line -match 'repo_config\s*=\s*{') {
            $inRepoConfig = $true
            continue
        }
        # Detect end of repo_config block. 
        if ($inRepoConfig -and $line -eq '}') {
            $inRepoConfig = $false
            break
        }
        if ($inRepoConfig -and $line -match '(\w+)\s*=\s*(.+)') {
            $key = $matches[1]
            $value = ($matches[2] -split '#')[0].Trim() # Remove comments after comments (#). 
            $value = $value.Trim('"') # Remove surrounding quotes.
            $repoConfig[$key] = $value
        }
    }
    return $repoConfig
}

# MAIN ======================================================== #

Clear-Host
Write-Host -ForegroundColor $HD1 "======================================================"
Write-Host -ForegroundColor $HD2 "     Bootstrap Script: Azure | GitHub | Terraform     "
Write-Host -ForegroundColor $HD1 "======================================================"
Write-Host

#=============================================#
# MAIN: Stage 1 - Validations & Pre-Checks
#=============================================#

# Validation: Required Applications and Authentication.
Write-Host -ForegroundColor $HD1 "[*] Validating required applications... " -NoNewLine
ForEach ($app in $requiredApps) {
    if (!(Get-Command $app.Command -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] ERROR: Required application '$($app.Name)' is missing. Please install and try again."
        exit 1
    }
    # Authentication checks. 
    if ($app.AuthCheck -ne "BYPASS") {
        Try {
            $session = (Invoke-Expression $app.AuthCheck -ErrorAction SilentlyContinue 2>&1)
            if ($LASTEXITCODE -eq 0) {
                New-Variable -Name "$($app.Command)Session" -Value $session -Force # Add app session details to variable.
            }
            else {
                Write-Host -ForegroundColor $ERR "FAIL"
                Write-Host -ForegroundColor $WRN "[!] WARNING: '$($app.Name)' is not authenticated. Please authenticate and try again."
                Write-Host -ForegroundColor $WRN "Login Command: '$($app.AuthLogin)'"
                exit 1
            }            
        }
        Catch {
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $WRN "[!] WARNING: '$($app.Name)' is not authenticated. Please authenticate and try again. $_"
            Write-Host -ForegroundColor $WRN "Login Command: '$($app.AuthLogin)'"
            exit 1
        }
    }
}
Write-Host -ForegroundColor $PASS "PASS"

# Validation: Confirm required variable files are present. 
Write-Host -ForegroundColor $HD1 "[*] Performing variable file checks... " -NoNewLine
Try {
    ForEach ($file in $var_files) {
        if (!(Test-Path -Path "$dir_ps_vars/$file")) {
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $ERR "[x] ERROR: Variable file '$file' not found! Please ensure file exists and try again."
            exit 1
        }
    }  
    Try {
        $repoConfig = Get-RepoConfig "$dir_ps_vars/global.tfvars"
        if ($repoConfig.repo) {
            Write-Host -ForegroundColor $PASS "PASS"
        }
        else {
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $ERR "[x] ERROR: Unable to extract repository details from variables file. Abort."
            exit 1
        }
    }
    Catch {
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] ERROR: Unable to extract repository details from variables file. Abort. $_"
        exit 1
    }
    Try {
        # Get subscription names from variables file.
        $bootstrap_subs = Get-Content "$dir_ps_vars/iac-bootstrap.tfvars.json" | ConvertFrom-Json
        $plz_sub_mgt = (az account list --query "[?contains(name, '$($bootstrap_subs.platform_subscription_identifiers.mgt)')].{Name:name, ID:id}" | ConvertFrom-Json)
        $plz_sub_gov = (az account list --query "[?contains(name, '$($bootstrap_subs.platform_subscription_identifiers.gov)')].{Name:name, ID:id}" | ConvertFrom-Json)
        $plz_sub_con = (az account list --query "[?contains(name, '$($bootstrap_subs.platform_subscription_identifiers.con)')].{Name:name, ID:id}" | ConvertFrom-Json)
    }
    Catch {
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] ERROR: Unable to extract subscription details from variables file. Abort. $_"
        exit 1
    }
}
Catch {
    Write-Host -ForegroundColor $ERR "FAIL"
    Write-Host -ForegroundColor $ERR "[x] ERROR: Failure occurred during variable file check. $_"
    exit 1  
}

if (-not $Remove) {
    # Enables Azure CLI to automatically install missing extensions whenever a command requires them, without asking for confirmation.
    Invoke-Expression "az config set extension.use_dynamic_install=yes_without_prompt --only-show-errors" >$null 2>&1
    # Disable auto-creation of Network Watcher. 
    Invoke-Expression "az feature register --namespace Microsoft.Network --name DisableNetworkWatcherAutocreation" >$null 2>&1

    # Azure Subscription Confirmation.
    Write-Host -ForegroundColor $HD1 "[*] Confirming target subscription for IaC backend... "
    Write-Host -ForegroundColor $HD1 "[*] Current Subscription: " -NoNewline
    Write-Host "$($azSession.id) ($($azSession.name))"
    if (!(Get-UserConfirm -prompt "Should this subscription be used for IaC bootstrapping [Y/N]?")) {
        Write-Host ""
        Write-Host -ForegroundColor $WRN "[!] WARN: User declined to proceed. Please set the correct subscription as active in the Azure CLI tool."
        Write-Host -ForegroundColor $WRN "[!] WARN: Please set the correct subscription as active in the Azure CLI tool."
        Write-Host ""
        Write-Host -ForegroundColor $HD1 "- List available subscriptions: " -NoNewline
        Write-Host "az account list"
        Write-Host -ForegroundColor $HD1 "- Select target subscription:   " -NoNewline
        Write-Host "az account set --subscription <ID>"
        Write-Host ""
        exit 1
    }
}

#================================================#
# MAIN: Stage 2 - Display Config / Actions
#================================================#
$bootstrap_subs

Write-Host ""
Write-Host -ForegroundColor $HD2 "==========================================================================================="
Write-Host -ForegroundColor $HD1 "Azure"
Write-Host "- Tenant:                      $($azSession.tenantId) ($($azSession.tenantDisplayName))"
Write-Host "- Current User:                $($azSession.user.name)"
Write-Host "- Subscription (IaC Backend):  $($azSession.id) ($($azSession.name))"
Write-Host "- Subscription (Management):   $($plz_sub_mgt.id) ($($plz_sub_mgt.name))"
Write-Host "- Subscription (Governance):   $($plz_sub_gov.id) ($($plz_sub_gov.name))"
Write-Host "- Subscription (Connectivity): $($plz_sub_con.id) ($($plz_sub_con.name))"
Write-Host ""
Write-Host -ForegroundColor $HD1 "Repository"
Write-Host "- Organization: $($repoConfig.org)"
Write-Host "- Repository:   $($repoConfig.repo)"
Write-Host "- Current User: $($ghSession.login)"
Write-Host ""
Write-Host -ForegroundColor $HD1 "Terraform"
Write-Host "- Terraform Directory: $dir_tf"
Write-Host "- Variables Directory: $dir_ps_vars"
Write-Host ""
Write-Host -ForegroundColor $HD1 "Action: " -NoNewLine; 
Write-Host -ForegroundColor $sys_action.colour "$($sys_action.name) [$($sys_action.symbol)]"
Write-Host ""
Write-Host -ForegroundColor $WRN "NOTE: Please ensure the above details are correct before proceeding."
Write-Host -ForegroundColor $WRN "If details above are incorrect, exit this script `
and make changes in related CLI tools before running this script again."
Write-Host -ForegroundColor $HD2 "==========================================================================================="
if (!(Get-UserConfirm -prompt "Do you wish to proceed [Y/N]?")) {
    Write-Host -ForegroundColor $WRN "[!] WARN: User declined to proceed. Exit."
    exit 1
}

#================================================#
# MAIN: Stage 3 - Execute Terraform
#================================================#

# Terraform: Initialize
Write-Host ""
Write-Host -ForegroundColor $HD1 "[*] Initializing Terraform configuration..."
Try {
    terraform -chdir="$dir_tf" init -upgrade
    if ($LASTEXITCODE -eq 0) {
        Write-Host -ForegroundColor $PASS "[+] PASS: Terraform is initialized."
    }
    else {
        Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform initialization failed. Please check configuration and try again."
        exit 1
    }
}
Catch {
    Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform initialization failed. Please check configuration and try again. $_"
    exit 1
}

if (!($Remove)) {
    # Terraform: Plan
    Write-Host ""
    Write-Host -ForegroundColor $HD1 "[*] Generating Terraform plan..."
    Try {
        terraform -chdir="$dir_tf" plan --out=bootstrap.plan `
            -var-file="$dir_ps_vars/$($var_files[0])" -var-file="$dir_ps_vars/$($var_files[1])" `
            -var="subscription_id=$($azSession.id)" #> $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            if (Test-Path -Path "$dir_tf/bootstrap.plan") {
                Write-Host -ForegroundColor $PASS "[+] PASS: Terraform plan created."
                terraform -chdir="$dir_tf" show bootstrap.plan            
            }
            else {
                Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform plan is not present! Please check configuration and try again."
                exit 1
            }
        }
        else {
            Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform plan failed. Please check configuration and try again."
            exit 1
        }
    }
    Catch {
        Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform plan failed. Please check configuration and try again. $_"
        exit 1
    }

    # Terraform: Apply
    Write-Host ""
    Write-Host -ForegroundColor $WRN "[!] Terraform will now apply changes. This may take several minutes to complete."
    if ((Get-UserConfirm -prompt "Do you wish to proceed [Y/N]?") ) {
        Write-Host -ForegroundColor $HD1 "[*] Running Terraform deployment..."
        Try {
            terraform -chdir="$dir_tf" apply bootstrap.plan
            if ($LASTEXITCODE -eq 0) {
                Write-Host -ForegroundColor $PASS "[+] PASS: Terraform plan has been applied successfully."
                Remove-Item -Path "$dir_tf/bootstrap.plan" -Force -ErrorAction SilentlyContinue
            }
            else {
                Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform plan failed to apply. Please check configuration and try again."
                exit 1
            }
        }
        Catch {
            Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform plan failed to apply. Please check configuration and try again. $_"
            exit 1
        }
    }
    else {
        Write-Host -ForegroundColor $WRN "[x] WARN: User aborted process. Please confirm intended configuration and try again."
        exit 1
    }
}

#================================================#
# MAIN: Stage 5 - State Migration
#================================================#

if (Test-Path -Path "$dir_tf/backend.tf") {
    # Already migrated (remote). Backend configuration already exists. 
    if ($Remove) {
        Try {
            # Pull from remote --> local
            terraform -chdir="$dir_tf" state pull > "$dir_tf/terraform.tfstate"
            if ($LASTEXITCODE -eq 0) {
                if (Test-Path "$dir_tf/terraform.tfstate") {
                    Write-Host -ForegroundColor $PASS "[+] PASS: Terraform state copied locally from remote."
                }
                else {
                    Write-Host -ForegroundColor $ERR "[x] FAIL: Local Terraform state is not present! Remote to local migration may have failed."
                    Rename-Item -Path "$dir_tf/backend.tf.bak" -NewName "$dir_tf/backend.tf" -ErrorAction SilentlyContinue # Rename file back to avoid issues when re-running. 
                    exit 1
                }
            }
            else {
                Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform failed during remote to local migration."
                Rename-Item -Path "$dir_tf/backend.tf.bak" -NewName "$dir_tf/backend.tf" -ErrorAction SilentlyContinue # Rename file back to avoid issues when re-running. 
                exit 1
            }

            # Rename existing backend config file. Remove existing backup if present. 
            if (Test-Path -Path "$dir_tf/backend.tf.bak") {
                Remove-Item -Path "$dir_tf/backend.tf.bak" -Force
            }
            Rename-Item -Path "$dir_tf/backend.tf" -NewName "$dir_tf/backend.tf.bak"

            # Reconfigure Terraform to use local state file.
            terraform -chdir="$dir_tf" init -migrate-state -input=false > $null 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host -ForegroundColor $PASS "[+] PASS: Terraform configured to use local state."
            }
            else {
                Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform failed to configure local state. Abort"
                Rename-Item -Path "$dir_tf/backend.tf.bak" -NewName "$dir_tf/backend.tf" -ErrorAction SilentlyContinue # Rename file back to avoid issues when re-running. 
                exit 1
            }
        }
        Catch {
            Write-Host -ForegroundColor $ERR "[x] FAIL: An error occurred during Terraform remote to local state migration. $_"
            Rename-Item -Path "$dir_tf/backend.tf.bak" -NewName "$dir_tf/backend.tf" # Rename file back to avoid issues when re-running. 
            exit 1
        }
    } 
    else {
        Write-Host -ForegroundColor $HD1 "[*] Existing backend configuration file detected. Skipping migration..."
    }
}
elseif (Test-Path -Path "$dir_tf/terraform.tfstate") {
    # Local state file present. Get backend variables from Terraform output. 
    if (!($Remove)) {
        # Already local, no need to pull down. 
        Write-Host -ForegroundColor $HD1 "[*] Local state detected. Retrieving Terraform backend details from output..."
        Try {
            $tfOutputs = terraform -chdir="$dir_tf" output -json | ConvertFrom-Json
            if ($LASTEXITCODE -eq 0) {
                $bootstrap_output = $tfOutputs.bootstrap_backend.value
                $tf_backend_resource_group = $bootstrap_output.resource_group
                $tf_backend_storage_account = $bootstrap_output.storage_account
                $tf_backend_blob_container = $bootstrap_output.blob_container
                $tf_backend_state_key = $bootstrap_output.state_key
                Write-Host "- Resource Group: $tf_backend_resource_group"
                Write-Host "- Storage Account: $tf_backend_storage_account"
                Write-Host "- Blob Container: $tf_backend_blob_container"
                Write-Host "- State File: $tf_backend_state_key"
                Write-Host -ForegroundColor $PASS "[+] PASS: Terraform outputs retrieved successfully."

                $tf_backend = @"
terraform {
  backend "azurerm" {
    resource_group_name  = "$($tf_backend_resource_group)"
    storage_account_name = "$($tf_backend_storage_account)"
    container_name       = "$($tf_backend_blob_container)"
    key                  = "$($tf_backend_state_key)"
    use_azuread_auth     = true # Force Entra ID for authorisation over Shared Access Keys.
  }
}
"@

                $tf_backend | Out-File -Encoding utf8 -FilePath "$dir_tf/backend.tf" -Force
                if (Test-Path -Path "$dir_tf/backend.tf") {
                    Write-Host -ForegroundColor $PASS "[+] PASS: Terraform backend file created."

                    # Perform remote migration. 
                    Write-Host -ForegroundColor $HD1 "[*] Migrating local Terraform state to Azure..."                    
                    terraform -chdir="$($dir_tf)" init -migrate-state -force-copy -input=false
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host -ForegroundColor $PASS "[+] PASS: Terraform state has been migrated successfully."
                        Remove-Item -Path "$dir_tf/terraform.tfstate" -Force
                    }
                    else {
                        Write-Host -ForegroundColor $ERR "[x] FAIL: An error occurred when attempting state migration. Investigation required. Abort."
                        exit 1
                    }
                }
                else {
                    Write-Host -ForegroundColor $ERR "[x] FAIL: Error creating Terraform backend file! Abort."
                    exit 1
                }            
            }
            else {
                Write-Host -ForegroundColor $ERR "[x] FAIL: Unable to obtain backend details from Terraform output. Abort."
                exit 1
            }
        }
        Catch {
            Write-Host -ForegroundColor $ERR "[x] Failed to get Terraform output values. Please check configuration and try again. $_"
            exit 1
        }
    }
}
else {
    # No local Terraform state or backend.tf file present. Something went wrong. 
    Write-Host -ForegroundColor $ERR "[x] Failed to locate local OR remote Terraform state. Unable to proceed. Abort."
    exit 1
}

#================================================#
# MAIN: Stage 6 - Remove/Destroy
#================================================#

if ($Remove) {
    # Confirm destroy with prompt. 
    if (!(Get-UserConfirm -prompt "Are you sure you want to destroy all resources [Y/N]?")) {
        Write-Host -ForegroundColor $WRN "[!] WARN: User aborted destroy. Exit."
        Rename-Item -Path "$dir_tf/backend.tf.bak" -NewName "$dir_tf/backend.tf" -ErrorAction SilentlyContinue # Rename file back to avoid issues when re-running. 
        exit 1
    }
    else {
        terraform -chdir="$dir_tf" destroy `
            -var-file="$dir_ps_vars/$($var_files[0])" `
            -var-file="$dir_ps_vars/$($var_files[1])" `
            -var="subscription_id=$($azSession.id)" `
            -auto-approve
        if ($LASTEXITCODE -eq 0) {
            # Clean up backend.tf and local state. 
            Remove-Item -Path "$dir_tf/backend.tf" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$dir_tf/terraform.tfstate" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$dir_tf/.terraform" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$dir_tf/.terraform.*" -Force -ErrorAction SilentlyContinue
            Write-Host -ForegroundColor $PASS "[+] PASS: Terraform destroy completed successfully."
        }
        else {
            Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform failed to remove resources. Investigation required."
            exit 1
        }
    }
}

#================================================#
# MAIN: Stage 7 - Clean Up
#================================================#
Remove-Item -Path "$dir_tf/.terraform" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$dir_tf/.terraform.*" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$dir_tf/*.plan" -Force -ErrorAction SilentlyContinue
Write-Host ""
if (!($Remove)) {
    Write-Host -ForegroundColor $WRN "NOTE: Manual approval may be required for pending API permissions assigned to the Service Principal."
}
Write-Host ""
Write-Host -ForegroundColor $HD1 "===== BOOTSTRAP SCRIPT COMPLETE ====="
Write-Host ""
