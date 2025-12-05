# Multiple VMs Example

Deploy multiple identical VMs using Terraform's `count` feature.

## Use Cases

- Web server pools
- Development/testing environments
- Kubernetes worker nodes
- Database clusters

## Usage

```bash
cd examples/multiple-vms

terraform init
terraform apply -var="vm_count=3" -var="vm_name_prefix=web"
```

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `vm_count` | Number of VMs to create | `3` |
| `vm_name_prefix` | Prefix for VM names | `vm` |

## Example

Create 5 web servers:

```hcl
# terraform.tfvars
nutanix_endpoint = "prism.example.com"
subnet_name      = "Your-Subnet"

vm_count       = 5
vm_name_prefix = "web"
image_name     = "ubuntu-24.04-cloud"

vcpus     = 2
memory_gb = 4
disk_gb   = 50

categories = {
  "Environment" = "Production"
  "Role"        = "WebServer"
}
```

This creates:
- web-01
- web-02
- web-03
- web-04
- web-05

## Outputs

```bash
# List all VM IPs
terraform output vm_ips

# Get summary
terraform output vm_summary
```

## Scaling

To change the number of VMs:

```bash
# Scale up to 5
terraform apply -var="vm_count=5"

# Scale down to 2 (WARNING: destroys VMs 3-5)
terraform apply -var="vm_count=2"
```
