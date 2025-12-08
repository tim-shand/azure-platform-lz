# Personal Home Lab

Welcome to my personal home lab! :wave:  

This project provides an environment for self-hosting and experimenting with different technologies.  
A base for hands-on learning, developing knowledge and improving skills in DevOps and Cloud platforms.  
Bootstrapped, deployed, and managed using Infra-as-Code and CI/CD workflows.  

As a big fan of small tech (think micro-pcs, Raspberry Pi etc), a primary requirement is maintaining a small footprint for my on-prem environment. I aim to re-use as much existing hardware as possible, recycling second hand gear and giving it a new life in my lab. 

![Photo of my current home lab setup.](docs/images/homelab.jpg)

---

## :computer: Physical Hardware (On-Prem)

### Hypervisors (Proxmox)

- 2x Lenovo Think Station P330 (Intel i5 9600T, 16GB DDR4, 250GB OS, 1TB ZFS pool). 
  - Running clustered [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) for VMs.  
  - Currently investigating NAS options to improve high availability and failover :eyes:. 
- 1x Raspberry Pi 1B+ (yes, very old)
  - Running as a QDevice, maintaining Proxmox cluster quorum [details on setup found here](https://www.tshand.com/p/home-lab-part-6-setup-qdevice-for-proxmox-quorum/).
  - Will be replaced and repurposed in future when I add a 3rd Proxmox node. 

### Networking

- **Switch:** TP-Link TL-SG108PE 8-Port Gigabit Easy Smart PoE Switch. 
  - Connecting nodes physically, providing outbound access to Internet via firewall connected to home WiFi network. 
- **Firewall:** HP EliteDesk G1 (Intel i5-4590T, 16 GB DDR3, 250 GB SSD). 
  - Running [OPNsense](https://opnsense.org/) providing firewall, DNS, VLAN and routing functionality. 
  - Separate VLANs for infrastructure, management and server workloads. 

---

## :cloud: Cloud Services

### Azure

- **Automated bootstrapping using Powershell + Terraform** 
  - Generates required Terraform files, kicks off the bootstrapping deployment, and triggers post-deployment state migration to Azure. 
  - Creates Entra ID Service Principal, secured with Federated Credentials (OIDC), adding the SP details as secrets to the specified GitHub repository. 
- **Platform Landing Zone** 
  - Minimalistic, light-weight platform landing zone for connectivity, governance, monitoring and shared resources. 
  - Hub/Spoke network topology, with hub VNet providing centralized connectivity for workload (spoke) VNet peering. 
- **IaC Backend Vending** 
  - Utilizes a dedicated IaC subscription to contain remote Terraform states, with per-project Azure Blob Containers and GitHUb ACtions environments for remote state management. 
  - Project backends are deployed using the `IaC Backend Vending` module to create Azure and GitHub resources. 

### Cloudflare

- Domain registrar and DNS provider for personal domains. 
- DNS zones updated using Terraform resources + API token stored in a repository secret. 

### GitHub + Actions

- Contains the overall project, and provides a centralized code repository. 
- GitHub Actions providing CI/CD by automating deployments using workflows. 
- Utilizing both top-level repository and environment variables/secrets for workload specific deployments. 

---

## :hammer_and_wrench: Deployment Tool Set

- **[Terraform](https://www.terraform.io/)**
  - Provider agnostic IaC tool, free to use, plenty of discussion, guides and support available. 
  - Deploy and manage on-prem and cloud resources using dedicated providers. 
  - Other considerations: Pulumi, OpenTofu. 
- **GitHub Actions: Self-hosted Runners (PENDING)**
  - Extends GitHub Actions workflows to allow management of on-prem environments. 
  - Can be run on a dedicated VM within Proxmox. 
- **Bash/Powershell**
  - Bootstrapping and misc utility scripts. 

---

## :jigsaw: Workloads

- **Firewall/Router:** Virtualized [pfSense](https://www.pfsense.org/download/) VM (for internal lab use). 
- **Virtual Machines:** Management/jump host servers, CI/CD runners, test and misc utility VMs. 
- **Personal Website (www.tshand.com) \[Azure\]**
  - Static website built with Hugo, deployed to Azure Static Web Apps using Terraform and GitHub workflows. 
  - Infra deployed from home lab repo, website source code located in separate GitHub repository. 
  - Workflow uses Azure SWA deployment token held as repo secret to trigger build on commit/PR. 

---

## :memo: To Do

- [ ] Setup self-hosted GitHub Runner on-prem. 
- [ ] Configure logging for hub networking to Log Analytics Workspace. 
- [ ] Investigate on-prem connectivity (VPN Gateway?). 
