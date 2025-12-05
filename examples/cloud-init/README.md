# Cloud-init Example

Deploy a Linux VM with automated configuration using cloud-init.

## Features

- Creates admin user with SSH key authentication
- Installs specified packages on first boot
- Enables Nutanix guest agent for VM tools
- Disables password authentication for security

## Usage

```bash
cd examples/cloud-init

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

terraform init
terraform apply
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `admin_username` | Admin user to create | `admin` |
| `ssh_authorized_keys` | SSH public keys to authorize | `[]` |
| `packages` | Additional packages to install | `[]` |

## Example terraform.tfvars

```hcl
nutanix_endpoint = "prism.example.com"
subnet_name      = "Your-Subnet"

vm_name        = "web-server-01"
admin_username = "deploy"

ssh_authorized_keys = [
  "ssh-ed25519 AAAAC3Nza... user@workstation"
]

packages = [
  "nginx",
  "certbot",
  "python3-certbot-nginx"
]
```

## Connecting

After deployment:

```bash
# Get the IP from Terraform output
terraform output ssh_command

# Connect
ssh deploy@<vm-ip>
```
