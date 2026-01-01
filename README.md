# Azure: Platform Landing Zone + Workloads

_Automated, IaC-driven Azure environment implementing governance, automation, and targeting operational best practices._

This repository contains my _personal_ Azure tenant, providing an enterprise-style environment for hands-on skill development. 
The project includes a platform landing zone, subscription management, monitoring, and CI/CD pipelines.  

Designed to be cost efficient, utilising free or low-cost options where possible, while maintaining a minimalistic footprint. 

---

## 🚀 Platform Landing Zone

Light-weight platform landing zone designed for personal use or by small organizations. IaC to deploy and manage shared resources, connectivity, governance, policy-as-code, monitoring and observability - aiming to align with CAF guidelines and best practice principals where possible.

- **Bootstrapping (Powershell + Terraform)** 
  - Provides the initial setup process, generating required Terraform files, and triggers post-deployment state migration to Azure. 
  - Creates Entra ID Service Principal, secured with Federated Credentials (OIDC), adding the details as secrets to GitHub repository. 
- **Governance & Policies**
  - Management groups, RBAC, and policy enforcement automated via Terraform modules, ensures scalable governance. 
- **Connectivity: Hub-Spoke Architecture**
  - Hub VNet for shared services with workload VNets peered as spokes for isolating environments. 
- **Observability & Monitoring**
  - Centralized Log Analytics workspace with diagnostic settings and alerting. 
- **IaC Backend Vending** 
  - Uses a dedicated subscription to contain all remote Terraform states. 
  - Environments/projects are deployed using the `IaC Backend Vending` module. 
  - Blob Containers per project for remote state management, with individual GitHub environments maintaining isolation between workloads. 

## ⚙️ Workloads

- **Personal Website (www.tshand.com)**
  - Static website built with Hugo, deployed to Azure Static Web Apps using Terraform and GitHub workflows. 
  - Separate repositories for infrastructure (this) and source code. 
  - Workflow uses Azure SWA deployment token held as repository secret, configured to trigger build on commit/PR. 

## 🛠️ Tooling & Automation

- **Terraform:** IaC tool for provisioning and managing Azure resources. 
- **Bash/Powershell:** Environment configuration, bootstrapping, automation, and misc utility scripts. 
- **GitHub Actions:** Providing CI/CD workflows for automating deployment processes. 

## 🧩 Project Structure

```shell
├── .github                         # GitHub workflows for automating builds.
├── docs                            # Design diagrams, build documents, images. 
├── environments                    # Global resources, landing zone, and workloads.  
│   ├── global
│   ├── platform-landing-zone       # Azure platform landing zone. 
│   └── workloads                   # Workloads running on Azure. 
├── modules                         # Terraform modules directory. 
│   ├── plz-governance
│   ├── plz-network-hub
│   ├── plz-observability
│   ├── swa-free-cloudflaredns
│   ├── vending-iac-backend
└── utilities                       # Utilities and tools used within the project. 
```

---

## 📝 To Do / Future Improvements

- [ ] Fix broken module paths. 
- [ ] Platform Landing Zone: Governance
- [ ] Platform Landing Zone: Observability
- [ ] Platform Landing Zone: Connectivity
- [ ] Platform Landing Zone: Security
- [ ] Subscription Vending
