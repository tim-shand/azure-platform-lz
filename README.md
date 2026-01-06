# Azure: Platform Landing Zone

_Automated, IaC-driven Azure platform landing zone, implementing governance, automation, and targeting operational best practices._

This repository contains my production Azure tenant, providing an enterprise-style environment for hands-on skill development. 
The project includes a platform landing zone, providing centralised shared services for workloads deployed within the tenant.   
Designed to be cost efficient, utilising free or low-cost options where possible, while maintaining a minimalistic footprint. 

---

## 🚀 Platform Landing Zone

Light-weight platform landing zone designed for personal use or by small organizations. Utilises IaC to deploy and manage shared resources, connectivity, governance, policy-as-code, monitoring and observability - aiming to align with CAF guidelines and best practice principals where possible.

- **Bootstrapping (Powershell + Terraform)** 
  - Provides the initial setup process for IaC.
  - Using templated Terraform configuration and triggering post-deployment state migration to new resources in Azure. 
  - Creates Entra ID Service Principal, secured with Federated Credentials (OIDC), adding the details as secrets into GitHub repository. 
- **Governance**
  - Management groups for policy hierarchy and subscription management. 
  - RBAC and policy assignments providing guard rails to secure the environment. 
- **Connectivity**
  - Hub-Spoke architecture, providing centralised network management and control. 
  - Workload VNets peered as spokes, isolating and securing environments. 
- **Management**
  - Centralized Log Analytics workspace for monitoring, with diagnostic settings applied via policy. 
  - Microsoft Defender for Cloud (Foundational CSPM) providing security posture information and recommendations. 
- **Identity**
  - Create groups within Entra ID for RBAC assignment. 
  - Automate the creation and management of groups, users, and PIM role assignments. 
- **IaC Backend Vending** 
  - Uses a dedicated Azure subscription, with Blob Containers per project to contain remote Terraform states for **all** projects. 
  - Custom `IaC Backend Vending` module to deploy Azure backend resources and GitHub environment configuration. 
  - Enables secure, intentional access via RBAC, while maintaining isolation between workloads. 

---

## 📊 Stack Deployment

1. **Bootstrap:** Manual process using Powershell and Terraform. 
2. **Vending IaC Backend:** Provision backend resources in Azure and GitHub environments per stack. 
2. **Management:** Create monitoring/observability resources, referenced by policies in Governance stack. 
3. **Governance:** Deploy Management Group structure and assign policies. 
4. **Connectivity:** Deploy networking resources providing hub-spoke arcitecture. 
5. **Identity:** Deploy Entra ID groups and RBAC assignments. 

---

## 🛠️ Tooling & Automation

- **Terraform:** Cloud-agnostic Infra-as-Code tool for deploying and managing resources in Azure.  
- **Powershell:** Environment configuration, bootstrapping, automation, and misc utility scripts. 
- **GitHub Actions:** Providing CI/CD workflows for automating deployment of processes. 

---

## 📝 To Do / Future Improvements

- [ ] Platform Landing Zone: Governance
- [ ] Platform Landing Zone: Management
- [ ] Platform Landing Zone: Connectivity
- [ ] Subscription Vending
