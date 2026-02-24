# Azure: Platform Landing Zone (Management Stack)

The Management stack deploys and configures the core shared operational services required to run and monitor the Azure Platform Landing Zone.
This stack provides centralized logging, monitoring, alerting, and policy-driven diagnostic configuration for all platform subscriptions. 
It is designed to be environment-agnostic, reusable, and aligned with enterprise Azure landing zone best practices. 

## 🌟 Features

- Centralized logging infrastructure (Log Analytics). 
- Platform-wide diagnostic configuration (via Azure Policy). 
- Activity Log alerting. 
- Action group notification routing. 
- Shared monitoring resources. 

### 🔍 Centralized Monitoring

**Provides a single location for:** 
- Platform logs. 
- Resource diagnostics. 
- Activity logs. 
- Security auditing. 
- Operational telemetry. 

### 📜 Policy-Driven Diagnostics

This stack assigns a pre-created policy initiatives that automatically deploy logging and diagnostic settings across platform resources. 

**The policy:** 
- Uses a managed identity (defined in the governance stack). 
  - Used to deploy diagnostic settings to resources. 
  - Maintain compliance automatically. 
- Sends logs to Log Analytics. 
- Enforces compliance continuously (via Azure Policy assignment). 
  - All current resources are monitored. 
  - Future resources automatically become compliant. 

### ⚠️ Alerting

**Implements standardized alert routing:** 
- Subscription Activity Log Alerts. 
  - Administrative operations. 
  - Service health issues. 
  - Resource health changes. 
  - Security-related events. 
- Category-based action groups (Platform, Security, Support). 
- Dynamic notification configuration. 

### 📨 Action Groups

Dynamic action groups are created based on TFVARS configuration.

- Severity-based notification routing. 
- Multiple email recipients. 
- Standardized alert schema. 

---

## ▶️ Usage

1. Update stack TFVARS file with required action group recipients. 
2. Deploy the stack using the related workflow in GitHub Actions. 
3. Validate outputs match desired state. 

---

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->