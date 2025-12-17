# Azure Platform: Personal Tenant

_Automated, IaC-driven Azure environment implementing governance, automation, and targeting operational best practices._

This repository contains my personal Azure tenant, providing enterprise-style operations and a sandbox for hands-on learning. It includes a platform landing zone, subscription management, monitoring, and CI/CD pipelines, aiming to align with CAF guidelines and best practice principals. 

---

## :cloud: Platform Landing Zone

Minimalistic, light-weight platform landing zone designed for personal use or by small organizations. IaC to deploy and manage shared resources, connectivity, governance, policy-as-code, monitoring/observability. 

- **Bootstrapping (Powershell + Terraform)** 
  - Provides the initial setup process, generating required Terraform files, and triggers post-deployment state migration to Azure. 
  - Creates Entra ID Service Principal, secured with Federated Credentials (OIDC), adding the details as secrets to GitHub repository. 
- **Governance & Policies**
  - Management groups, RBAC, and policy enforcement automated via Terraform modules, ensures scalable governance. 
- **Observability & Monitoring**
  - Centralized Log Analytics workspace with diagnostic settings and alerting. 
- **Networking / Hub-Spoke Architecture**
  - Hub VNet for shared services with workload VNets peered as spokes for isolated environments. 
- **IaC Backend Vending** 
  - Dedicated IaC subscription to contain all remote Terraform states, deployed using the custom `IaC Backend Vending` module. 
  - Blob Containers per project for remote state management, with individual GitHub environments maintaining isolation between workloads. 

## :gear: Workloads

- **Personal Website (www.tshand.com)**
  - Static website built with Hugo, deployed to Azure Static Web Apps using Terraform and GitHub workflows. 
  - Separate repositories for infrastructure (this) and source code. 
  - Workflow uses Azure SWA deployment token held as repository secret, configured to trigger build on commit/PR. 

---

## :hammer_and_wrench: Tooling & Automation

- **Terraform:** IaC tool for provisioning and managing Azure resources. 
- **Bash/Powershell:** Environment configuration, bootstrapping, automation, and misc utility scripts. 
- **GitHub Actions:** Providing CI/CD workflows for automating deployment processes. 

---

## :jigsaw: Project Structure

```shell
environments/        # Global resources, landing zone, and workloads
modules/             # Reusable Terraform modules (governance, networking, observability, IaC backends)
docs/                # Architecture overview, STAR talking points, diagrams
README.md            # Overview and purpose
```
---

## :memo: To Do / Future Improvements

- [ ] Platform Landing Zone: Governance
- [ ] Platform Landing Zone: Observability
- [ ] Platform Landing Zone: Connectivity
- [ ] Platform Landing Zone: Security
- [ ] Subscription Vending
