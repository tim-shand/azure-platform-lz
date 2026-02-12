# IDENTITY: General
# ------------------------------------------------------------- #

output "azuread_groups_adm" {
  description = "Map of privilaged Entra ID groups."
  value = {
    for k, v in azuread_group.grp_adm :
    k => {
      id           = v.id
      object_id    = v.object_id
      display_name = v.display_name
      description  = v.description
    }
  }
}

output "azuread_groups_usr" {
  description = "Map of standard Entra ID groups."
  value = {
    for k, v in azuread_group.grp_usr :
    k => {
      id           = v.id
      object_id    = v.object_id
      display_name = v.display_name
      description  = v.description
    }
  }
}
