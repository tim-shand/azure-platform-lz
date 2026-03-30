# Root Management Group: Pass in tenant ID to get root management group.
data "azurerm_management_group" "tenant_root" {
  name = data.azuread_client_config.current.tenant_id # Obtained from current session. 
}

# GitHub: Get data for existing GitHub Repository. 
data "github_repository" "repo" {
  full_name = "${var.global.repo_config.org}/${var.global.repo_config.repo}"
}
