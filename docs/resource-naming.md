## Naming Conventions

This project uses a single naming template for platform and workload resources to ensure consistency, readability, and CAF alignment. 

**Template:** `<prefix>-<workload>-<stack_or_env>-<category>-<resource_type>-<instance>`  

| Segment         | Purpose / Description                                                                                        |
| --------------- | ------------------------------------------------------------------------------------------------------------ |
| `prefix`        | Tenant or project identifier, `abc` (Animal Balloon Company)                                                 |
| `workload`      | `plz` for platform, workload name for apps/services (`mywebapp`)                                             |
| `stack_or_env`  | Platform stack (`gov`, `con`, `mgt`, `sec`) **or** environment (`dev`, `tst`, `stg`, `prd`)                  |
| `category`      | Optional category grouping: `hub`, `fwl`, `bas` (used mainly for PLZ resources, optional for workloads)      |
| `resource_type` | Azure resource type abbreviation: `rg`, `vnet`, `snet`, `app`, `sql`, `api`, etc.                            |
| `instance`      | Numeric identifier: `01`, `02`, `03` (for multiple similar resources)                                        |

### Examples: Platform

| Resource                    | Name Example              | Notes                               |
| --------------------------- | ------------------------- | ----------------------------------- |
| Connectivity Resource Group | `abc-plz-con-rg-01`       | Resource Group for hub connectivity |
| Azure Firewall              | `abc-plz-con-fwl-01`      | Azure Firewall or NVA appliance     |
| Hub VNet                    | `abc-plz-con-hub-vnet-01` | Central hub virtual network         |
| Bastion Subnet              | `abc-plz-con-bas-snet-01` | Subnet for Azure Bastion            |
| VPN Gateway Subnet          | `abc-plz-con-gwy-snet-01` | Subnet for VPN Gateway              |
| Firewall Subnet             | `abc-plz-con-fwl-snet-01` | Subnet for Azure Firewall           |
| Management Subnet           | `abc-plz-con-mgt-snet-01` | Subnet for monitoring/management    |

### Examples: Workload

| Resource     | Name Example              | Notes                            |
| ------------ | ------------------------- | -------------------------------- |
| Web App      | `abc-mywebapp-prd-app-01` | Category omitted for simplicity  |
| SQL Database | `abc-mywebapp-prd-sql-01` | Environment identifies lifecycle |
| API Function | `abc-mywebapp-prd-api-01` | Category omitted, optional       |

### Abbreviation Reference: Categories 

| Abbreviation | Meaning                   |
| ------------ | ------------------------- |
| hub          | Hub network               |
| bas          | Bastion subnet            |
| gwy          | VPN Gateway subnet        |
| fwl          | Firewall / Azure Firewall |
| mgt          | Management subnet         |

### Abbreviation Reference: Resource Types 

| Abbreviation | Meaning               |
| ------------ | --------------------- |
| rg           | Resource Group        |
| vnet         | Virtual Network       |
| snet         | Subnet                |
| app          | App Service / Web App |
| sql          | SQL Database          |
| api          | API / Function        |

---
