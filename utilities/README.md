# Utilities

_List of tools and utilities used within this project._

## Bootstrap: Azure and GitHub

Custom process using Powershell and Terraform to bootstrap Azure and GitHub for IaC automation. 

```powershell
# Execute bootstrapping process. 
powershell -file utilities/bootstrap-azure-github/bootstrap-azure-github.ps1 -EnvFile "env.psd1" -Action Create
```

## [Terraform Docs](https://terraform-docs.io/)

Used to produce Terraform module information, such as required providers, inputs and outputs. 

```shell
# Use existing configuration files, and provide path to perform task. 
terraform-docs --config utilities\terraform-docs\tfdocs-modules.yml modules/my_module_path
```

