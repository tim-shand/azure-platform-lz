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
    [Parameter(Mandatory=$true)][string]$EnvFile
)

# Required applications and validation commands.
$requiredApps = @(
    [PSCustomObject]@{ 
        Name = "Azure CLI"; 
        Command = "az"; 
        AuthCheck = "az account show --only-show-errors | ConvertFrom-JSON"; 
        LoginCmd = "az login --use-device-code";
        AccessCheck = 'az account subscription show --subscription-id $config.Azure.SubscriptionIAC -o json --only-show-errors | ConvertFrom-JSON'
    }
    [PSCustomObject]@{ 
        Name = "GitHub CLI"; 
        Command = "gh"; 
        AuthCheck = "gh api user | ConvertFrom-JSON"; 
        LoginCmd = "gh auth login";
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
if($destroy){
    $sys_action = @{
        do = "Remove"
        past = "Removed"
        current = "Removing"
        colour = "Magenta"
        symbol = "[-]"
    }
} else{
    $sys_action = @{
        do = "Create"
        past = "Created"
        current= "Creating"
        colour = "Green"
        symbol = "[+]"
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

#===================================================#
# MAIN
#===================================================#
Clear-Host
Write-Host -ForegroundColor $HD1 "`r`n======================================================"
Write-Host -ForegroundColor $HD2 "     Bootstrap Script: Azure | Github | Terraform     "
Write-Host -ForegroundColor $HD1 "======================================================`r`n"

# Test if Windows or Unix (Linux/MacOS), adjust pathing accordingly.
if(((Get-ChildItem -Path Env:OS).value) -eq "Windows_NT"){
    $workingDir = "$PSScriptRoot\"
} else{
    $workingDir = "$PSScriptRoot/"
}

# Validation: Provided variables file. Check path exists and values can be queried. 
$env_file = "$($workingDir)$EnvFile"
Write-Host -ForegroundColor $HD1 -NoNewLine "[*] Validating provided variables file... "
if(!(Test-Path -Path $env_file)){
    Write-Host -ForegroundColor $ERR "FAIL"
    Write-Host -ForegroundColor $ERR "[x] ERROR: Required variables file not found! Please create it and try again."
    exit 1
} else{
    Try{
        # Import variables from file into '$config' variable.
        $config = Import-PowerShellDataFile -Path $env_file
        if($config.azure.naming.prefix){
            Write-Host -ForegroundColor $INF "PASS"
        } else{
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $ERR "[x] ERROR: Provided variable formatting is invalid. Please check and try again."
            exit 1
        }
    }
    Catch{
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] ERROR: Failed to load variables file! $_"
        exit 1
    }
}

# Validation: Required Applications and Authentication.
ForEach($app in $requiredApps){
    Write-Host -ForegroundColor $HD1 -NoNewLine "[*] Checking application '$($app.name)'... "
    # Check if application is install by executing its primary command.
    if(!(Get-Command $app.Command -ErrorAction SilentlyContinue 2>&1)){
        Write-Host -ForegroundColor $ERR "FAIL"
        Write-Host -ForegroundColor $ERR "[x] ERROR: Required application '$($app.name)' is missing. Please install it and try again."
        exit 1
    } else{
        # Check is application is authenticated. If not, prompt to authenticate.
        if(!(Invoke-Expression $app.AuthCheck -ErrorAction SilentlyContinue 2>&1)){
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $WRN "[!] WARNING: Required application '$($app.name)' is not authenticated!"
            if(Get-UserConfirm -prompt "Do you wish to proceed with login [Y/N]?"){
                Invoke-Expression $app.LoginCmd
            } else{
                Write-Host -ForegroundColor $WRN "[!] WARNING: User declined to proceed with authentication. Exit."
                exit 1
            }
        }
        # Test access to resources.
        if(!(Invoke-Expression $app.AccessCheck -ErrorAction SilentlyContinue 2>&1)){
            Write-Host -ForegroundColor $ERR "FAIL"
            Write-Host -ForegroundColor $ERR "[x] ERROR: Failed access check for application '$($app.name)'. Please check environment permissions and try again."
            exit 1
        } else{
            Write-Host -ForegroundColor $INF "PASS"
        }
    }
    # Get current authenticated application session into dynamic variables (azSession, ghSession).
    New-Variable -Name "$($app.Command)Session" -Value (Invoke-Expression $app.AuthCheck -ErrorAction SilentlyContinue) -Force
    New-Variable -Name "$($app.Command)Access" -Value (Invoke-Expression $app.AccessCheck -ErrorAction SilentlyContinue) -Force
}

Invoke-Expression "az config set extension.use_dynamic_install=yes_without_prompt --only-show-errors" >$null 2>&1

# MAIN: Display Configuration
Write-Host ""
Write-Host -ForegroundColor Cyan "Azure: " -NoNewLine; Write-Host -ForegroundColor Yellow "(User: $($azSession.user.name))"
Write-Host "- Tenant ID: $($azSession.tenantId)"
Write-Host "- Tenant Name: $($azSession.tenantDisplayName)"
Write-Host "- Subscription ID: $($azAccess.subscriptionId)"
Write-Host "- Subscription Name: $($azAccess.displayName)"
Write-Host "- Default Location: $($config.Azure.Location)"
Write-Host ""
Write-Host -ForegroundColor Cyan "GitHub: " -NoNewLine; Write-Host -ForegroundColor Yellow "(User: $($ghSession.login))"
Write-Host "- Owner/Org: $(($ghSession.html_url).Replace('https://github.com/',''))"
Write-Host "- Repository: $($config.GitHub.Repo) [$($config.GitHub.Branch)]"
Write-Host "- Write Access: $($ghAccess.user.permissions.push)"
Write-Host ""
Write-Host -ForegroundColor Cyan "Deployment Action: " -NoNewLine; 
Write-Host -ForegroundColor $($sys_action.colour) "$($sys_action.do) $($sys_action.symbol)"

