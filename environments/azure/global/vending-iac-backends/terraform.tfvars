#=================================================================#
# Vending: Azure IaC Backends
#=================================================================#

# Github Configuration.
github_config = {
  owner = "tim-shand"
  repo = "homelab"
}

# Object of projects that require IaC backend.
projects = {
  "azure-platform-lz" = { 
    create_github_env = true
    subscription_id_env = "8cf80f38-0042-413a-a0ac-c65663dda28e"
  }
  "azure-workload-wwwtshandcom" = { 
    create_github_env = true
    subscription_id_env = "9173fb12-e761-49ab-8a72-fc4c578ff87b"
  }
}
