#=================================================================#
# Vending: IaC Backends
#=================================================================#

# Object of projects that require IaC backend.
projects = {
  "azure-mgt-platformlz" = {
    create_github_env = true  # Enable creation of GitHub repository environment.
    enable_dev_state  = false # Enable to create additional 'TF_BACKEND_KEY_DEV' environment variable.
  }
  "azure-wrk-wwwtshandcom" = {
    create_github_env = true # Enable creation of GitHub repository environment.
    enable_dev_state  = true # Enable to create additional 'TF_BACKEND_KEY_DEV' environment variable.
  }
}
