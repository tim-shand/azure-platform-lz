# Azure: Platform Landing Zone (STACK: Governance)

## Overview

This stack deploys a light-weight, CAF-aligned governance layer. This stack provides basic security and management controls using built-in Azure Policy initiatives, running in Audit mode by default, and is designed to be low-cost and provide minimal complexity.

- One JSON file = One Policy Definition
- Tag enforcement for resources (Environment, Owner).
- HTTPS-only enforcement for storage accounts.
- Allowed locations to restrict deployments to approved regions.

## Process

- Deploy management group hierarchy. 
- Deploy policy definitions & initiatives. 
- Deploy policy assignments. 

- Creates Storage Account and Table to contain "global outputs"; details of shared services resources (Hub VNet, Log Analytics Workspace). 

---

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
