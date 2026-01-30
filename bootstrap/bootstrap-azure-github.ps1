<#======= Bootstrap: Azure & GitHub for Terraform =======#
# DESCRIPTION:
Bootstrap script to prepare Azure tenant for management via Terraform and GitHub Actions.
- Checks for required local applications (see variable `$requiredApps`).
- Validates Azure and GitHub CLI authentication, obtains information from current sessions.
- Deploys Azure and GitHub resources as defined in Terraform bootstrap module. 

# REQUIRED:
- Install: Azure CLI, GitHub CLI.
- Existing Azure subscription dedicated to IaC purposes (or platform general). 
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

# Required applications and validation commands.
$requiredApps = @(
    [PSCustomObject]@{Name = "Azure CLI"; Command = "az"; AuthCheck = "az account show --only-show-errors | ConvertFrom-JSON"; }
    [PSCustomObject]@{Name = "GitHub CLI"; Command = "gh"; AuthCheck = "gh api user | ConvertFrom-JSON"; }
    [PSCustomObject]@{Name = "Terraform"; Command = "terraform"; AuthCheck = "BYPASS"; }
)

# Directories, Files and Misc.
$dir_tf = "$PSScriptRoot/terraform" # Location of Terraform files. 
$dir_ps_vars = "$PSScriptRoot/../variables" # Location of Terraform variable files (in relation project root).
$tf_backend_state_key = "azure-iac-bootstrap.tfstate" # Terraform state file name.
$var_files = @("global.tfvars", "iac-bootstrap.tfvars") # Array of required variable files for bootstrap process. 

# Terminal Colours.
$PASS = "Green"
$WRN = "Yellow"
$ERR = "Red"
$HD1 = "Cyan"
$HD2 = "Magenta"

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

# Function: Get repository details from TFVARS file.
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

#=============================================#
# MAIN: Stage 1 - Validations & Pre-Checks
#=============================================#
Clear-Host
Write-Host -ForegroundColor $HD1 "======================================================"
Write-Host -ForegroundColor $HD2 "     Bootstrap Script: Azure | GitHub | Terraform     "
Write-Host -ForegroundColor $HD1 "======================================================`r`n"

# Validation: Confirm required variable files are present. 
Write-Host -ForegroundColor $HD1 "[*] Performing variable file checks..."
Try {
    ForEach ($file in $var_files) {
        if (!(Test-Path -Path "$dir_ps_vars/$file")) {
            Write-Host -ForegroundColor $ERR "[x] FAIL: Variable file '$file' not found! Please ensure file exists and try again."
            exit 1
        }
    }
    Write-Host -ForegroundColor $PASS "[+] PASS: Variable files are present."
    $repoConfig = Get-RepoConfig "$dir_ps_vars/global.tfvars"
}
Catch {
    Write-Host -ForegroundColor $ERR "[x] FAIL: Error occurred during variable file check. $_"
    exit 1  
}

# Validation: Required Applications and Authentication.
Write-Host -ForegroundColor $HD1 "[*] Validating required applications..."
ForEach ($app in $requiredApps) {
    if (!(Get-Command $app.Command -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor $ERR "[x] FAIL: Required application '$($app.Name)' is missing."
        exit 1
    }
    # Authentication checks. 
    if ($app.AuthCheck -ne "BYPASS") {
        Try {
            $session = (Invoke-Expression $app.AuthCheck -ErrorAction SilentlyContinue 2>&1)
            New-Variable -Name "$($app.Command)Session" -Value $session -Force # Add app session details to variable.

        }
        Catch {
            Write-Host -ForegroundColor $WRN "[!] WARN: '$($app.Name)' is not authenticated. Please authenticate and try again."
            exit 1
        }
    }
}
Invoke-Expression "az config set extension.use_dynamic_install=yes_without_prompt --only-show-errors" >$null 2>&1
Write-Host -ForegroundColor $PASS "[+] PASS: All required applications are installed and authenticated."

#================================================#
# MAIN: Stage 2 - Display Config / Actions
#================================================#

Write-Host ""
Write-Host -ForegroundColor $HD1 "Azure --------------------------------------------"
Write-Host "- Tenant ID: $($azSession.tenantId)"
Write-Host "- Tenant Name: $($azSession.tenantDisplayName)"
Write-Host "- Subscription ID: $($azSession.id)"
Write-Host "- Subscription Name: $($azSession.name)"
Write-Host "- Current User: $($azSession.user.name)"
Write-Host ""
Write-Host -ForegroundColor $HD1 "Repository ---------------------------------------"
Write-Host "- Organisation: $($repoConfig.org)"
Write-Host "- Repository: $($repoConfig.repo)"
Write-Host "- Current User: $($ghSession.login)"
Write-Host ""
Write-Host -ForegroundColor $HD1 "Action: " -NoNewLine; 
Write-Host -ForegroundColor $sys_action.colour "$($sys_action.name) [$($sys_action.symbol)]"
Write-Host ""
Write-Host -ForegroundColor $WRN "NOTE: Please ensure the above details are correct before proceeding."
Write-Host -ForegroundColor $WRN "If details above are incorrect, exit this script and make changes within CLI tools before re-running this script."
Write-Host ""
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
    terraform -chdir="$dir_tf" init -upgrade > $null 2>&1
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

# Terraform: Plan
Write-Host ""
Write-Host -ForegroundColor $HD1 "[*] Generating Terraform plan..."
Try {
    terraform -chdir="$dir_tf" plan --out=bootstrap.plan `
        -var-file="$dir_ps_vars/$($var_files[0])" -var-file="$dir_ps_vars/$($var_files[1])" `
        -var="subscription_id=$($azSession.id)" > $null 2>&1
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


#================================================#
# MAIN: Stage 5 - State Migration
#================================================#

if (Test-Path -Path "$dir_tf/backend.tf") {
    # Already migrated (remote). Backend configuration already exists. 
    if ($Remove) {
        # Pull from remote --> local
        Try {
            # Rename existing backend config file. Remove existing backup if present. 
            if (Test-Path -Path "$dir_tf/backend.tf.bak") {
                Remove-Item -Path "$dir_tf/backend.tf.bak" -Force
            }
            Rename-Item -Path "$dir_tf/backend.tf" -NewName "$dir_tf/backend.tf.bak"
            # Execute state pull from remote to local. 
            terraform -chdir="$dir_tf" init -input=false > $null 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host -ForegroundColor $PASS "[+] PASS: Terraform state successfully copied locally."
                if (Test-Path "$dir_tf/terraform.tfstate") {
                    Write-Host -ForegroundColor $PASS "[+] PASS: Local Terraform state file present."
                }
                else {
                    Write-Host -ForegroundColor $ERR "[x] FAIL: Local Terraform state is not present! Remote to local migration may have failed."
                    Rename-Item -Path "$dir_tf/backend.tf.bak" -NewName "$dir_tf/backend.tf" # Rename file back to avoid issues when re-running. 
                    exit 1
                }
            }
            else {
                Write-Host -ForegroundColor $ERR "[x] FAIL: Terraform failed during remote to local migration."
                Rename-Item -Path "$dir_tf/backend.tf.bak" -NewName "$dir_tf/backend.tf" # Rename file back to avoid issues when re-running. 
                exit 1
            }
        }
        Catch {
            Write-Host -ForegroundColor $ERR "[x] FAIL: An error occurred during Terraform remote to local migration. $_"
            Rename-Item -Path "$dir_tf/backend.tf.bak" -NewName "$dir_tf/backend.tf" # Rename file back to avoid issues when re-running. 
            exit 1
        }
        Finally {
            # Restore backend.tf if something went wrong. 
            if (!(Test-Path "$dir_tf/backend.tf") -and (Test-Path "$dir_tf/backend.tf.bak")) {
                Write-Host -ForegroundColor $WRN "[!] WARN: Restoring backend.tf from backup..."
                Try {
                    Rename-Item "$dir_tf/backend.tf.bak" -NewName "$dir_tf/backend.tf" -Force
                }
                Catch {
                    Write-Host -ForegroundColor $ERR "[x] FAIL: Unable to restore backend configuration file! $_"
                }
            }
        }
    } 
    else {
        Write-Host -ForegroundColor $HD1 "[*] Existing backend configuration detected. Skipping migration..."
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
                $deployments = $tfOutputs.deployments.value
                $tf_backend_resource_group = $deployments.bootstrap.backend_resource_group
                $tf_backend_storage_account = $deployments.bootstrap.backend_storage_account
                $tf_backend_container = $deployments.bootstrap.backend_blob_container
                Write-Host "- Resource Group: $tf_backend_resource_group"
                Write-Host "- Storage Account: $tf_backend_storage_account"
                Write-Host "- Blob Continer: $tf_backend_container"
                Write-Host "- State File: $tf_backend_state_key"
                Write-Host -ForegroundColor $PASS "[+] PASS: Terraform outputs retrieved successfully."

                $tf_backend = @"
terraform {
  backend "azurerm" {
    resource_group_name  = "$($tf_backend_resource_group)"
    storage_account_name = "$($tf_backend_storage_account)"
    container_name       = "$($tf_backend_container)"
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
# MAIN: Stage 6 - Clean Up
#================================================#
#Remove-Item -Path "$dir_tf/.terraform*" -Recurse -Force -ErrorAction SilentlyContinue
#Remove-Item -Path "$dir_tf/.terraform.*" -Force -ErrorAction SilentlyContinue
Write-Host ""
if (!($Remove)) {
    Write-Host -ForegroundColor $WRN "NOTE: Manual approval may be required for pending API permissions assigned to the Service Principal."
}
Write-Host ""
Write-Host -ForegroundColor $HD1 "===== BOOTSTRAP SCRIPT COMPLETE ====="
Write-Host ""
