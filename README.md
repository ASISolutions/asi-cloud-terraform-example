# ASI Cloud Terraform Examples

Terraform configurations for deploying and managing resources on [ASI Cloud](https://www.asi.co.nz/cloud/), powered by Nutanix AHV.

## Overview

ASI Cloud provides Infrastructure-as-a-Service (IaaS) built on Nutanix hyperconverged infrastructure. This repository contains Terraform examples to help you automate VM provisioning and management.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- ASI Cloud account with API access
- Prism Central credentials (provided by ASI)

## Quick Start

```bash
# Clone this repository
git clone https://github.com/ASISolutions/asi-cloud-terraform-example.git
cd asi-cloud-terraform-example

# Copy and configure your variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your credentials and VM settings

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply
```

## Authentication

ASI Cloud uses Nutanix Prism Central for API access. You'll need:

| Credential | Description |
|------------|-------------|
| `nutanix_endpoint` | Prism Central IP/hostname (provided by ASI) |
| `nutanix_username` | Your Prism Central username |
| `nutanix_password` | Your Prism Central password |

### Secure Credential Management

**Never commit credentials to version control.** Use one of these methods:

#### Option 1: Environment Variables (Recommended)

```bash
export TF_VAR_nutanix_username="your-username"
export TF_VAR_nutanix_password="your-password"
terraform plan
```

#### Option 2: terraform.tfvars (Local Only)

```hcl
# terraform.tfvars (add to .gitignore)
nutanix_username = "your-username"
nutanix_password = "your-password"
```

## Examples

| Example | Description |
|---------|-------------|
| [Basic VM](.) | Single VM with DHCP networking |
| [examples/static-ip](examples/static-ip/) | VM with static IP configuration |
| [examples/multiple-vms](examples/multiple-vms/) | Deploy multiple VMs using count |
| [examples/cloud-init](examples/cloud-init/) | Linux VM with cloud-init customization |

## Resources

### Virtual Machines

The primary resource is `nutanix_virtual_machine`:

```hcl
resource "nutanix_virtual_machine" "example" {
  name         = "my-vm"
  cluster_uuid = data.nutanix_clusters.clusters.entities[0].metadata.uuid

  num_sockets          = 2
  num_vcpus_per_socket = 1
  memory_size_mib      = 4096

  disk_list {
    disk_size_mib = 51200  # 50 GB

    data_source_reference = {
      kind = "image"
      uuid = data.nutanix_image.ubuntu.id
    }
  }

  nic_list {
    subnet_uuid = data.nutanix_subnet.default.id
  }
}
```

### Data Sources

Common data sources for discovering existing resources:

```hcl
# Get cluster UUID
data "nutanix_clusters" "clusters" {}

# Get subnet by name
data "nutanix_subnet" "default" {
  subnet_name = "Your-Subnet-Name"
}

# Get image by name
data "nutanix_image" "ubuntu" {
  image_name = "ubuntu-24.04-cloud"
}
```

## VM Sizing Guide

| Size | vCPUs | Memory | Disk | Use Case |
|------|-------|--------|------|----------|
| Small | 1 | 2 GB | 20 GB | Dev/test, lightweight services |
| Medium | 2 | 4 GB | 50 GB | Web servers, small databases |
| Large | 4 | 8 GB | 100 GB | Application servers |
| XLarge | 8 | 16 GB | 200 GB | Database servers, heavy workloads |

## Networking

ASI Cloud provides VLAN-based networking. Your assigned subnet will have:

- **DHCP**: Automatic IP assignment (recommended for most use cases)
- **Static IP**: Manual IP assignment within your allocated range

Contact ASI Support for your subnet details and available IP ranges.

## Images

Available OS images (request additional images from ASI Support):

| Image Name | Description |
|------------|-------------|
| `ubuntu-24.04-cloud` | Ubuntu 24.04 LTS with cloud-init |
| `ubuntu-22.04-cloud` | Ubuntu 22.04 LTS with cloud-init |
| `windows-2022-std` | Windows Server 2022 Standard |
| `windows-2019-std` | Windows Server 2019 Standard |

## State Management

For production use, configure remote state storage:

```hcl
terraform {
  backend "s3" {
    bucket   = "your-tfstate-bucket"
    key      = "asi-cloud/terraform.tfstate"
    region   = "ap-southeast-2"
    encrypt  = true
  }
}
```

## Support

- **Documentation**: [ASI Cloud Docs](https://docs.asi.co.nz/cloud/)
- **Support Portal**: [support.asi.co.nz](https://support.asi.co.nz)
- **Email**: cloud@asi.co.nz

## License

Apache 2.0 - See [LICENSE](LICENSE) for details.

## Contributing

Issues and pull requests welcome. Please ensure:
- No credentials or sensitive data in commits
- Test configurations before submitting
- Follow existing code style
