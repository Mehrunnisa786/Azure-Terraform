# Azure Infrastructure Automation with Terraform & Azure DevOps CI/CD

Automated provisioning of Azure infrastructure using Terraform, with a full CI/CD pipeline built on Azure DevOps. Includes remote state management, multi-stage pipeline with manual approval gates, and clean resource lifecycle management.

---

## Architecture Overview

```
Developer (VSCode)
      │
      ▼
Azure Repos (Git) ──► Azure Build Pipeline (CI) ──► Azure Release Pipeline (CD)
                              │                              │
                         Build Stage                   Deploy Stage
                         - tf install                  - tf install
                         - tf init                     - tf init
                         - tf validate                 - tf apply
                         - tf fmt                           │
                         - tf plan                    [Manual Approval]
                         - tf archive                       │
                         - tf publish              Destroy Stage
                                                   - tf install
                                                   - tf init
                                                   - tf destroy
```

---

## Infrastructure Provisioned

| Resource | Name | Details |
|---|---|---|
| Resource Group | `demo-resources` | South India |
| Virtual Network | `demo-network` | 10.0.0.0/16 |
| Subnet | `internal` | 10.0.2.0/24 |
| Network Interface | `demo-nic` | Attached to subnet |
| Virtual Machine | `demo-vm` | Standard_B2s_v2, Ubuntu |

---

## Remote Backend

Terraform state is stored remotely in Azure Blob Storage:

| Setting | Value |
|---|---|
| Resource Group | `demo-resource` |
| Storage Account | `trainwithafrahh` |
| Container | `tfstate` |
| State File | `terraform.tfstate` |

---

## Project Structure

```
├── main.tf                  # Core infrastructure resources
├── provider.tf              # Azure provider configuration
├── backend.tf               # Remote state backend config
├── variables.tf             # Input variables
├── terraform.tfvars         # Variable values
├── azure-pipelines.yml      # Azure DevOps CI/CD pipeline
└── .gitignore               # Excludes secrets, state files, .terraform/
```

---

## CI/CD Pipeline Stages

### Stage 1 — Build (CI)
Triggered automatically on every push to `main`.

| Step | Description |
|---|---|
| tf install | Installs latest Terraform on the agent |
| tf init | Initializes backend and downloads providers |
| tf validate | Validates HCL syntax |
| tf fmt | Checks code formatting |
| tf plan | Generates execution plan, saves to `tfplanfile` |
| tf archive | Zips workspace including plan file |
| tf publish | Publishes artifact for use in CD stages |

### Stage 2 — Deploy (CD)
Downloads the artifact from Build stage and applies the saved plan.

| Step | Description |
|---|---|
| Get Artifacts | Downloads published build artifact |
| Extract files | Unzips the workspace |
| tf install | Installs Terraform |
| tf init | Re-initializes with remote backend |
| tf apply | Applies the saved plan (`-auto-approve tfplanfile`) |

### Stage 3 — Destroy (CD)
Runs only after manual approval. Tears down all provisioned infrastructure.

| Step | Description |
|---|---|
| Get Artifacts | Downloads published build artifact |
| Extract files | Unzips the workspace |
| tf install | Installs Terraform |
| tf init | Re-initializes with remote backend |
| tf destroy | Destroys all resources (`-auto-approve`) |

> **Approval Gate:** The Destroy stage requires manual approval via the `production-destroy` environment in Azure DevOps before it will run.

---

## Prerequisites

- Azure subscription with sufficient quota
- Azure DevOps organization and project
- [Terraform Azure DevOps extension](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks) installed
- Azure service connection configured in Azure DevOps
- Backend storage account and container created manually before first run

### Create backend storage (one-time setup)

```bash
az group create --name demo-resource --location southindia

az storage account create \
  --name trainwithafrahh \
  --resource-group demo-resource \
  --location southindia \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name trainwithafrahh
```

---

## Setup & Usage

### 1. Clone the repo

```bash
git clone https://dev.azure.com/mehrunnisaafrah/terraform-pipeline/_git/terraform-pipeline
cd terraform-pipeline
```

### 2. Update service connection name

In `azure-pipelines.yml`, set your Azure DevOps service connection name:

```yaml
variables:
  SERVICECONNECTION: 'your-service-connection-name'
```

### 3. Create environments with approval gates

In Azure DevOps → Pipelines → Environments:
- Create `production` (approval gate for Deploy)
- Create `production-destroy` (approval gate for Destroy)

### 4. Run the pipeline

Push any change to `main` to trigger the Build stage automatically:

```bash
git add .
git commit -m "your message"
git push origin main
```

---

## Security

- Secrets and credentials are **never stored in code**
- `.gitignore` excludes `secrets.txt`, `*.tfvars`, `.terraform/`, and state files
- GitHub push protection is enabled — any accidental secret commits will be blocked
- Azure credentials are passed via the service connection, not hardcoded

---

## Tech Stack

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Microsoft_Azure-0089D6?style=flat&logo=microsoft-azure&logoColor=white)
![Azure DevOps](https://img.shields.io/badge/Azure_DevOps-0078D7?style=flat&logo=azure-devops&logoColor=white)

- **IaC:** Terraform 1.15+ with AzureRM provider v4.1.0
- **CI/CD:** Azure DevOps Pipelines (YAML-based, multi-stage)
- **Cloud:** Microsoft Azure (South India region)
- **State Management:** Azure Blob Storage (remote backend)
