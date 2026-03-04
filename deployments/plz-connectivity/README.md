# Azure: Platform Landing Zone (Connectivity Stack)

This stack deploys the Connectivity resources for a custom, light-weight, CAF-aligned platform landing zone in Azure.

## 🌟 Features

- Hub-Spoke architecture, providing centralized network management and flow control.
- Workload VNets to be peered with the hub VNet as spokes, utilizing User-Defined-Routes (UDR) to direct traffic via Azure Firewall (if enabled).
- VPN Gateway for on-prem connectivity with hub virtual network.
- Azure Bastion for remote access to via RDP or SSH to virtual machines.

## ▶️ Usage

**NOTE:** Automatic creation of Network Watcher is enabled by default. Use the below commands to disable this to allow Terraform to manage the deployment.

```powershell
# Disable auto-creation of Network Watcher. 
az feature register --namespace Microsoft.Network --name DisableNetworkWatcherAutocreation
```

1. Review and populate variables defined in the `./variables/plz-connectivity.tfvars` file.
2. Update Hub VNet subnets with desired configuration. **DO NOT** edit the key structure as this is opinionated and will break deployments.
3. Run the stack workflow from within GitHub Actions.
