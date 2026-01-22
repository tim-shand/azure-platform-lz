<#======= Bootstrap: Azure & GitHub for Terraform =======#
# REQUIRED:
- Populate "bootstrap.psd1" file with required values. 
- Install: Azure CLI, GitHub CLI.
- Existing Azure subscription dedicated to IaC purposes (or platform general).
- Existing GitHub repository for project secrets and variables. 

# DESCRIPTION:
Bootstrap script to prepare Azure tenant for management via Terraform and GitHub Actions.
- Checks for required local applications (see variable `$requiredApps`).
- Confirms required user-defined variables have been set.
- Validates Azure CLI authentication, obtains Azure tenant information from current session.
- Validates GitHub CLI authentication, confirms access to provided target repository.
- Azure:
  - Creates Service Principal (App Registration) in Entra ID to be used for IaC.
  - Adds federated credentials (OIDC) for GitHub repository/branch to the Service Principal.
  - Assigns RBAC roles to Service Principal for managing tenant root group.
  - Set current user and Service Principal to the "owner" of the Service Principal.
  - Assign Microsoft Graph API permissions to allow self-updating of federated credentials for future vending.
  - Create IaC backend resources: Resource Groups, Storage Accounts, Blob Containers. 
- GitHub:
  - Add Azure tenant and subscription details as repository secrets. 
  - Create GitHub repository environments per deployment stack. 
  - Add created Azure resource details as repository environment variables.

# USAGE:
./deployments/bootstrap/bootstrap-azure-github.ps1
#=======================================================#>

# SCRIPT VARIABLES =============================================#
# Command line input parameters.
param(
    [switch]$Remove # Add switch parameter for removal option.
)

# Required applications and validation commands.
$requiredApps = @(
    [PSCustomObject]@{ 
        Name        = "Azure CLI"; 
        Command     = "az"; 
        AuthCheck   = "az account show --only-show-errors | ConvertFrom-JSON"; 
        AccessCheck = 'az account subscription show --subscription-id $config.subscription_id_iac -o json --only-show-errors | ConvertFrom-JSON'
    }
    [PSCustomObject]@{ 
        Name        = "GitHub CLI"; 
        Command     = "gh"; 
        AuthCheck   = "gh api user | ConvertFrom-JSON"; 
        AccessCheck = '(gh api /repos/$($config.global.repo_config.org)/$($config.global.repo_config.org)/collaborators/$($config.global.repo_config.org)/permission | ConvertFrom-JSON).user.permissions'
    }
)

# Directories, Files and Misc.
$env_file = "$PSScriptRoot/bootstrap.psd1" # PowerShell variables file. 
$dir_tf_files = "$PSScriptRoot/terraform" # Location of Terraform files. 
$dir_templates = "$PSScriptRoot/templates" # Directory for TFVAR file templates. 
$dir_script_tfvars = "./variables" # Location of Terraform variable files (in relation to Terraform files).
$tf_backend_state_key = "azure-iac-bootstrap.tfstate" # Terraform state file name.

# Terminal Colours.
$INF = "Green"
$WRN = "Yellow"
$ERR = "Red"
$HD1 = "Cyan"
$HD2 = "Magenta"

# Determine request action and populate hashtable for output purposes.
if ($Remove) {
    $tf_plan_action = "plan -destroy"
    $tf_action = "destroy"    
    $sys_action = @{
        do      = "Remove"
        past    = "Removed"
        current = "Removing"
        colour  = "Magenta"
        symbol  = "[-]"
    }
}
else {
    $tf_plan_action = "plan"
    $tf_action = "apply"    
    if (Test-Path -Path "$dir_tf_files/backend.tf") {
        # An existing backend file is detected, assume deployment executed previously. 
        $backend_exists = $true
        $sys_action = @{
            do      = "Update"
            past    = "Updated"
            current = "Updating"
            colour  = "Yellow"
            symbol  = "[~]"
        }     
    }
    else {
        $sys_action = @{
            do      = "Deploy"
            past    = "Deployed"
            current = "Deploying"
            colour  = "Green"
            symbol  = "[+]"
        }
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
Write-Host -ForegroundColor $HD2 "     Bootstrap Script: Azure | GitHub | Terraform     "
Write-Host -ForegroundColor $HD1 "======================================================`r`n"

# Validation: Provided variables file. Check path exists and values can be queried. 
Write-Host -ForegroundColor $HD1 -NoNewLine "[-] Validating local variables file... "
if (!(Test-Path -Path $env_file)) {
    Write-Host -ForegroundColor $ERR "FAIL"
    Write-Host -ForegroundColor $ERR "[x] ERROR: Required variables file not found! Please create it and try again."
    exit 1
}
else {
    Try {
        # Import variables from file into '$config' variable.
        $config = Import-PowerShellDataFile -Path $env_file
        if ($config.global.repo_config) {
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
    Write-Host -ForegroundColor $HD1 -NoNewLine "[-] Checking application '$($app.name)'... "
    # Check if application is install by executing its primary command.
    if (!(Get-Command $app.Command -ErrorAction SilentlyContinue 2>&1)) {
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] ERROR: Required application '$($app.name)' is missing. Please install and try again."
        exit 1
    }
    else {
        # Check is application is authenticated. If not, prompt to authenticate.
        if (!(Invoke-Expression $app.AuthCheck -ErrorAction SilentlyContinue 2>&1)) {
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $WRN "[!] WARN: Required application '$($app.name)' is not authenticated! Please authenticate and try again."
        }
        # Test access to resources.
        if (!(Invoke-Expression $app.AccessCheck -ErrorAction SilentlyContinue 2>&1)) {
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $ERR "[x] ERROR: Failed access check for application '$($app.name)'. Please check authentication/permissions and try again."
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
Write-Host -ForegroundColor $HD1 "Azure --------------------------------------------"
Write-Host "- Tenant ID: $($azSession.tenantId)"
Write-Host "- Tenant Name: $($azSession.tenantDisplayName)"
Write-Host "- Subscription ID: $($azAccess.subscriptionId)"
Write-Host "- Subscription Name: $($azAccess.displayName)"
Write-Host "- Default Location: $($config.global.locations.default)"
Write-Host "- Current User: $($azSession.user.name)"
Write-Host ""
Write-Host -ForegroundColor $HD1 "Repository ---------------------------------------"
Write-Host "- Owner/Org: $(($ghSession.html_url).Replace('https://github.com/',''))"
Write-Host "- Repository: $($config.global.repo_config.repo) [$($config.global.repo_config.Branch)]"
Write-Host "- Current User: $($ghSession.login)"
Write-Host "- Access: $(($ghAccess.PSObject.Properties | Where-Object {$_.Value -eq $true} | ForEach-Object {$_.Name}) -join ", ")"
Write-Host ""
if ($backend_exists) {
    Write-Host -ForegroundColor $sys_action.colour "*** Existing backend file found! Assuming update ***"
}
Write-Host -ForegroundColor $HD1 "Action: " -NoNewLine; 
Write-Host -ForegroundColor $sys_action.colour "$($sys_action.do) $($sys_action.symbol)"
Write-Host -ForegroundColor $HD1 "Please ensure the above details are correct before proceeding."
Write-Host ""
if (!(Get-UserConfirm -prompt "Do you wish to proceed [Y/N]?")) {
    Write-Host -ForegroundColor $WRN "[!] WARN: User declined to proceed. Exit."
    exit 1
}

#================================================#
# MAIN: Stage 3 - Prepare Terraform Variables
#================================================#
Write-Host ""
Write-Host -ForegroundColor $HD1 "[-] Performing Action: Generating Terraform variable files... " -NoNewLine

# Variables: Bootstrap
Try {
    $template_bootstrap = (Get-Content -Path "$dir_templates/bootstrap.tmpl" -Raw)
    $template_bootstrap_replace = @(
        [PSCustomObject]@{ Find = "{subscription_id_iac}"; Replace = "$($config.subscription_id_iac)"; }
        [PSCustomObject]@{ Find = "{subscription_id_con}"; Replace = "$($config.subscription_id_con)"; }
        [PSCustomObject]@{ Find = "{subscription_id_gov}"; Replace = "$($config.subscription_id_gov)"; }
        [PSCustomObject]@{ Find = "{subscription_id_mgt}"; Replace = "$($config.subscription_id_mgt)"; }
        [PSCustomObject]@{ Find = "{subscription_id_idn}"; Replace = "$($config.subscription_id_idn)"; }
    )
    ForEach ($entry in $template_bootstrap_replace) {
        $template_bootstrap = $template_bootstrap.Replace($entry.Find, $entry.Replace)
    }
    $template_bootstrap | Out-File -Encoding utf8 -FilePath "$dir_script_tfvars/bootstrap.tfvars" -Force
    Write-Host -ForegroundColor $INF "PASS"
}
Catch {
    Write-Host -ForegroundColor $ERR "FAIL" 
    Write-Host -ForegroundColor $ERR "[x] ERROR: Failed to generate Terraform variable file (bootstrap). $_"
    exit 1
}

# Variables: Global
Try {
    $template_global = (Get-Content -Path "$dir_templates/global.tmpl" -Raw)
    $template_global_replace = @(
        [PSCustomObject]@{ Find = "{global_location_default}"; Replace = "$($config.global.locations.default)"; }
        [PSCustomObject]@{ Find = "{global_location_secondary}"; Replace = "$($config.global.locations.secondary)"; }
        [PSCustomObject]@{ Find = "{global_naming_org_code}"; Replace = "$($config.global.naming.org_code)"; }
        [PSCustomObject]@{ Find = "{global_naming_project_name}"; Replace = "$($config.global.naming.project_name)"; }
        [PSCustomObject]@{ Find = "{global_naming_environment}"; Replace = "$($config.global.naming.environment)"; }
        [PSCustomObject]@{ Find = "{global_tags_organisation}"; Replace = "$($config.global.tags.organisation)"; }
        [PSCustomObject]@{ Find = "{global_tags_owner}"; Replace = "$($config.global.tags.owner)"; }
        [PSCustomObject]@{ Find = "{global_tags_environment}"; Replace = "$($config.global.tags.environment)"; }
        [PSCustomObject]@{ Find = "{global_tags_project}"; Replace = "$($config.global.tags.project)"; }
        [PSCustomObject]@{ Find = "{global_tags_createdby}"; Replace = "$($config.global.tags.createdby)"; }
        [PSCustomObject]@{ Find = "{global_repo_config_org}"; Replace = "$($config.global.repo_config.org)"; }
        [PSCustomObject]@{ Find = "{global_repo_config_repo}"; Replace = "$($config.global.repo_config.repo)"; }
        [PSCustomObject]@{ Find = "{global_repo_config_branch}"; Replace = "$($config.global.repo_config.branch)"; }
    )
    ForEach ($entry in $template_global_replace) {
        $template_global = $template_global.Replace($entry.Find, $entry.Replace)
    }
    $template_global | Out-File -Encoding utf8 -FilePath "$dir_script_tfvars/global.tfvars" -Force
}
Catch {
    Write-Host -ForegroundColor $ERR "FAIL" 
    Write-Host -ForegroundColor $ERR "[x] ERROR: Failed to generate Terraform variable file (global). $_"
    exit 1
}

# Confirm Terraform variable files have been created. 
if (!((Test-Path -Path "$dir_script_tfvars/global.tfvars") -and (Test-Path -Path "$dir_script_tfvars/bootstrap.tfvars"))) {
    Write-Host -ForegroundColor $ERR "FAIL" 
    Write-Host -ForegroundColor $ERR "[x] ERROR: Terraform variable files not found! Abort."
    exit 1
}

#===================================================#
# MAIN: Stage 4 - Execute Terraform (Deploy/Remove)
#===================================================#

# Terraform: Initialize
Write-Host ""
Write-Host -ForegroundColor $HD1 "[-] Performing Action: Initialize Terraform configuration... " -NoNewLine
if (terraform -chdir="$dir_tf_files" init -upgrade) {
    Write-Host -ForegroundColor $INF "PASS"
}
else {
    Write-Host -ForegroundColor $ERR "FAIL" 
    Write-Host -ForegroundColor $ERR "[x] ERROR: Terraform initialization failed. Please check configuration and try again."
    exit 1
}

# Destroy --------------------|
# Pull remote state file back to local (backup), or use existing local state file. 
if ($Remove) {
    # Migrate remote state back to local and remove local backend file. 
    if (Test-Path -Path "$dir_tf_files/backend.tf") {
        Write-Host ""
        Write-Host -ForegroundColor $HD1 "[-] Pulling remote Terraform state from Azure... " -NoNewline
        terraform -chdir="$dir_tf_files" state pull > "$dir_tf_files/$($tf_backend_state_key).bak" # Backup remote.
        terraform -chdir="$dir_tf_files" state pull > "$dir_tf_files/terraform.tfstate" # Rename local copy. 
        if (Test-Path -Path "$dir_tf_files/$($tf_backend_state_key).bak") {
            Write-Host -ForegroundColor $INF "PASS"
            Rename-Item -Path "$dir_tf_files/backend.tf" -NewName "$dir_tf_files/backend.bak" -Force -ErrorAction SilentlyContinue
            # Re-initialise Terraform post state migration. 
            Write-Host -ForegroundColor $HD1 "[-] Reconfiguring Terraform... " -NoNewline
            if (terraform -chdir="$dir_tf_files" init -migrate-state) {
                Write-Host -ForegroundColor $INF "PASS" 
            }
            else {
                Write-Host -ForegroundColor $ERR "ERROR"
                Write-Host -ForegroundColor $ERR "[x] ERROR: Failed to re-initialise Terraform!"
                exit 1
            }
        }
        else {
            Write-Host -ForegroundColor $ERR "ERROR"
            Write-Host -ForegroundColor $ERR "[x] ERROR: Failed to pull Terraform state back to local. Please check configuration or download manually."
            exit 1
        }
    }
    else {
        # Check for local file (download from remote storage and place in Terraform directory).
        if (Test-Path -Path "$dir_tf_files/terraform.tfstate") {
            Write-Host -ForegroundColor $WRN "[!] WARN: Backend configuration (backend.tf) is missing. Defaulting to using local state file."
        }
        else {
            Write-Host -ForegroundColor $ERR "[x] ERROR: Local state file is missing. Please download from remote backend and try again." 
            exit 1
        }
    }
}

# Terraform: Plan --------------------|
Write-Host ""
Write-Host -ForegroundColor $HD1 "[-] Performing Action: Running Terraform plan... " -NoNewLine
if (terraform -chdir="$dir_tf_files" $($tf_plan_action) --out=bootstrap.plan -var-file="../../../$dir_script_tfvars/bootstrap.tfvars" -var-file="../../../$dir_script_tfvars/global.tfvars") {
    Write-Host -ForegroundColor $INF "PASS" 
    terraform -chdir="$dir_tf_files" show bootstrap.plan
}
else {
    Write-Host -ForegroundColor $ERR "FAIL" 
    Write-Host -ForegroundColor $ERR "[x] ERROR: Terraform plan failed. Please check configuration and try again."
    exit 1
}

# Terraform: Apply / Destroy --------------------|
Write-Host ""
if (Test-Path -Path "$dir_tf_files/bootstrap.plan") {
    Write-Host -ForegroundColor $WRN "[!] Terraform will now deploy changes. This may take several minutes to complete."
    if (!(Get-UserConfirm -prompt "Do you wish to proceed [Y/N]?") ) {
        Write-Host -ForegroundColor $ERR "[x] ERROR: User aborted process. Please confirm intended configuration and try again."
        exit 1
    }
    else {
        Write-Host -ForegroundColor $HD1 "[-] Performing Action: Running Terraform $($tf_action)... "
        Try {
            terraform -chdir="$($dir_tf_files)" apply bootstrap.plan
        }
        Catch {
            Write-Host "FAIL" -ForegroundColor $ERR
            Write-Host -ForegroundColor $ERR "[x] ERROR: Terraform $($tf_action) failed. Please check configuration and try again. $_"
            exit 1
        }
    }
}
else {
    Write-Host -ForegroundColor $ERR "[x] Terraform plan file missing! Please check configuration and try again."
    exit 1  
}

#================================================#
# MAIN: Stage 5 - Migrate State to Azure
#================================================#

if (!($Remove)) {
    # Get Github variables from Terraform output.
    Write-Host -ForegroundColor $HD1 "[-] Retrieving Terraform backend details from output... " -NoNewLine
    Try {
        $tf_backend_resource_group = terraform -chdir="$($dir_tf_files)" output -raw bootstrap_iac_rg
        $tf_backend_storage_account = terraform -chdir="$($dir_tf_files)" output -raw bootstrap_iac_sa
        $tf_backend_container = terraform -chdir="$($dir_tf_files)" output -raw bootstrap_iac_cn
        Write-Host -ForegroundColor $INF "PASS"
        Write-Host ""
        Write-Host "- Resource Group: $tf_backend_resource_group"
        Write-Host "- Storage Account: $tf_backend_storage_account"
        Write-Host "- Blob Continer: $tf_backend_container"
        Write-Host "- State File: $tf_backend_state_key"
    }
    Catch {
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] Failed to get Terraform output values. Please check configuration and try again."
        exit 1
    }

    # Backend: Create post deployment. 
    Try {
        $template_backend = (Get-Content -Path "$dir_templates/backend.tmpl" -Raw)
        $template_backend_replace = @(
            [PSCustomObject]@{ Find = "{tf_backend_resource_group}"; Replace = "$tf_backend_resource_group"; }
            [PSCustomObject]@{ Find = "{tf_backend_storage_account}"; Replace = "$tf_backend_storage_account"; }
            [PSCustomObject]@{ Find = "{tf_backend_container}"; Replace = "$tf_backend_container"; }
            [PSCustomObject]@{ Find = "{tf_backend_state_key}"; Replace = "$tf_backend_state_key"; }
        )
        ForEach ($entry in $template_backend_replace) {
            $template_backend = $template_backend.Replace($entry.Find, $entry.Replace)
        }
        $template_backend | Out-File -Encoding utf8 -FilePath "$dir_tf_files/backend.tf" -Force
    }
    Catch {
        Write-Host -ForegroundColor $ERR "FAIL" 
        Write-Host -ForegroundColor $ERR "[x] ERROR: Failed to generate Terraform backend file. $_"
        exit 1
    }

    # Terraform: Migrate State

    Write-Host ""
    if (!($backend_exists)) {
        Write-Host -ForegroundColor $WRN "[!] Terraform will now migrate state to Azure... "
        if (Get-UserConfirm -prompt "Do you wish to proceed [Y/N]?") {
            Write-Host ""
            Write-Host -ForegroundColor $HD1 "[-] Migrating Terraform state to Azure... " -NoNewline
            if (terraform -chdir="$($dir_tf_files)" init -migrate-state -force-copy -input=false) {
                Write-Host -ForegroundColor $INF "PASS"
                Remove-Item -Path "$dir_tf_files/terraform.tfstate" -Force -ErrorAction SilentlyContinue
            }
            else {
                Write-Host -ForegroundColor $ERR "FAIL"
                Write-Host -ForegroundColor $ERR "[x] Failed to migrate Terraform state to Azure. Please check configuration and try again."
            }
        }
        else {
            Write-Host -ForegroundColor $WRN "[!] Terraform state migration aborted by user."
            #Remove-Item -Path "$dir_tf_files/backend.tf" -Force -ErrorAction SilentlyContinue
        }
    }
}

#================================================#
# MAIN: Stage 6 - Clean Up
#================================================#
Remove-Item -Path "$dir_tf_files/bootstrap.plan" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$dir_tf_files/.terraform*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$dir_tf_files/.terraform.*" -Force -ErrorAction SilentlyContinue
Write-Host ""
if (!($Remove)) {
    Write-Host -ForegroundColor $WRN "NOTE: Manual approval may be required for pending API permissions assigned to the Service Principal."
}
Write-Host ""
Write-Host -ForegroundColor $HD1 "===== BOOTSTRAP SCRIPT COMPLETE ====="
Write-Host ""
