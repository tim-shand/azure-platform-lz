# Azure: Platform Landing Zone (Identity Stack)

This Terraform stack manages the base Azure Entra ID groups for the platform landing zone. It establishes core identity groups that can be used by other deployment stacks for RBAC assignments. 

## 🌟 Overview

The Identity stack is responsible for:

- Creating privileged administrator groups in Entra ID (Azure AD).
- Creating standard user/team groups in Entra ID.
- This stack does not create managed identities, resource groups, or Key Vaults — those are handled by the Management stack.
- **Note:** Only groups marked as Active = true in TFVARS will be created. 

---

## 🏦 Architecture

- **Entra ID Groups:** 
  - GRP_ADM_* = Privileged administrator roles. 
  - GRP_USR_* = Standard user or team roles. 

```text
Azure Tenant
 └─ Identity Stack
     ├─ Entra ID Admin Groups (GRP_ADM_*)
     └─ Entra ID User Groups (GRP_USR_*)
```

---

## ▶️ Usage

1. Update stack TFVARS file with required group configurations. 
2. Deploy the stack using the related workflow in GitHub Actions. 
3. Validate outputs match desired state. 

---

