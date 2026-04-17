output "service_principal" {
  description = "Map detailing properties of the pipeline Service Principal."
  value = {
    object_id    = azuread_application.iac_sp.object_id       # Object ID.
    client_id    = azuread_application.iac_sp.client_id       # App ID (aka Client ID). 
    sp_id        = azuread_service_principal.iac_sp.object_id # Service Principal object ID.
    display_name = azuread_application.iac_sp.display_name    # App Registration display name. 
  }
}

output "bootstrap_backend" {
  description = "Map of bootstrap backend details for state file migration."
  value = {
    resource_group  = azurerm_resource_group.iac.name
    storage_account = azurerm_storage_account.backend["platform"].name
    blob_container  = azurerm_storage_container.backend["bootstrap"].name
    state_key       = "${lower(var.deployment_stacks.bootstrap.stack_name)}.tfstate"
  }
}

# output "platform_subscription_ids" {
#   description = "Map of platform subscriptions IDs per stack."
#   value = {
#     for k, v in local.deployment_stacks_subscriptions :
#     k => v.subscription_id
#   }
# }

output "github_environments" {
  description = "Map of GitHub environments per stack, including subscription ID."
  value = {
    for k, v in github_repository_environment.gh_env :
    #for k,v in var.deployment_stacks :
    k => {
      repository = try(github_repository_environment.gh_env[k].repository, "N/A")
      environment = try(github_repository_environment.gh_env[k].environment, "N/A")
      subscription_id = try(github_actions_environment_variable.subscription[k].value, "N/A")
      container = try(github_actions_environment_variable.container[k].value, "N/A")
      state_key = try(github_actions_environment_variable.key[k].value, "N/A")
    }
  }
}
