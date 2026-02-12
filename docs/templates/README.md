# Terraform Docs

Used to produce Terraform module information, such as required providers, inputs and outputs. 

[Terraform Docs](https://terraform-docs.io/)

```shell
# Use existing configuration files, and provide path to perform task. 
terraform-docs --config docs/templates/tfdocs-modules.yml modules/my_module_path

# STACKS:
terraform-docs --config docs/templates/tfdocs-root.yml deployments/plz-governance
terraform-docs --config docs/templates/tfdocs-root.yml deployments/plz-identity
terraform-docs --config docs/templates/tfdocs-root.yml deployments/plz-management
terraform-docs --config docs/templates/tfdocs-root.yml deployments/plz-connectivity
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

