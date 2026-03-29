# ☁️ Azure Platform Landing Zone (Custom)

This project contains a custom Azure platform landing zone (PLZ), inspired by enterprise-scale architecture and based on CAF guidelines.  
Designed to be light-weight and cost-efficient, utilizing free or minimum pricing SKU options where possible.  
Ideal for a small organization, personal tenant, light production or development/training purposes.  

- **Infrastructure as Code (IaC) + CI/CD**
  - Git-driven workflow, with a merge or commit to the `main` branch triggering automation pipelines.
  - Desired state of environment declared in code, using Terraform to define Azure resources and components.
  - Secrets and variables stored in GitHub repository, referenced and passed during workflow run-time.
- **State Segmentation**
  - Utilizes a dedicated subscription, containing state files remotely in Azure Blob storage.
  - Separate state files per deployment stack, reducing blast radius in case of corruption or loss.
- **Powershell Bootstrapping**
  - Locally executed [Powershell script](./deployments/bootstrap) automates initial setup process.
  - Prepares both Azure tenant and GitHub repository for automated deployments using Terraform.

---

