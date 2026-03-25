# Azure: Platform Landing Zone (Connectivity Stack)

This stack deploys the Connectivity resources for a custom, light-weight, CAF-aligned platform landing zone in Azure.

## ✨ Features

- Implements a hub-and-spoke network architecture for centralized network management and secure traffic flow.
- Spoke VNets connect to the hub VNet using VNet peering, with optional User-Defined Routes (UDRs) directing traffic through Azure Firewall.
- Azure Firewall provides centralized network security and traffic inspection for hub and spoke workloads.
- Network Security Groups (NSGs) enforce rule-based traffic controls at the subnet levels.

---

## ▶️ Usage

> [!NOTE]
> Automatic creation of Network Watcher is enabled by default. Use the below commands to disable this to allow Terraform to manage the deployment.

```shell
# Disable auto-creation of Network Watcher. 
az feature register --namespace Microsoft.Network --name DisableNetworkWatcherAutocreation
```

1. Review and populate variables defined in the `./variables/plz-connectivity.tfvars` file.
2. Update Hub VNet subnets with desired configuration. **DO NOT** edit the key structure as this is opinionated and will break deployments.
3. Run the stack workflow from within GitHub Actions.

---
