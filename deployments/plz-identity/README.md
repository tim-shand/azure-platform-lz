# Azure: Platform Landing Zone (Identity Stack)

The Identity stack is responsible for managing Entra ID groups used across your Azure landing zone.  
This stack centralises the creation of administrator and user groups, ensuring consistent naming, ownership, and active status management.

## ✨ Features

The Identity Stack manages Entra ID resources required for the platform. This includes:

- Admin and User groups created from TFVARS definitions.
- Only groups marked as active are created.
- Owners are resolved dynamically using employee IDs.
- Group names follow enterprise prefix conventions.
- Groups are security-enabled and duplicate names are prevented.

---

## 🏦 Design Layout

- **Entra ID Groups:**
  - GRP_ADM_* = Privileged administrator roles.
  - GRP_USR_* = Standard user or team roles.
  - Owners = assigned to each group via employee ID.

```text
Azure Tenant
 └─ Identity Stack
     ├─ Entra ID Admin Groups (GRP_ADM_*)
     └─ Entra ID User Groups (GRP_USR_*)
```

---

## ▶️ Usage

1. Update stack TFVARS file with required group configurations, including owner employee ID.
2. Deploy the stack using the related workflow in GitHub Actions.
3. Validate outputs match desired state.

**Example TFVARS:**  

```hcl
# Entra ID: Set naming format. 
entra_groups_admins_prefix = "GRP_ADM_" # GRP_ADM_NetworkAdmins
entra_groups_users_prefix  = "GRP_USR_" # GRP_ADM_NetworkAdmins

# Admin Groups. 
entra_groups_admins = {
  "NetworkAdmins" = {
    description       = "RBAC - Privilaged Group: Network Administrators"
    active            = true          # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "STAFF123456" # Use dummy employee ID as this is public repo. 
  }
  "PlatformAdmins" = {
    description       = "RBAC - Privilaged Group: Platform Administrators"
    active            = true          # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "STAFF123456" # Use dummy employee ID as this is public repo. 
  }
}

# User Groups. 
entra_groups_users = {
  "FinanceTeam" = {
    description       = "User Access: Finance Department"
    active            = true          # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "STAFF998800" # Use dummy employee ID as this is public repo. 
  }
  "ManagementTeam" = {
    description       = "User Access: Management Department"
    active            = true          # Enable/disable group in Entra (setting from 'true' to 'false' will remove the group). 
    owner_employee_id = "STAFF998800" # Use dummy employee ID as this is public repo. 
  }
}
```

---
