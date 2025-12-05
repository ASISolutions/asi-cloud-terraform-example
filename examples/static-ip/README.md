# Static IP Example

Deploy a VM with a specific IP address instead of DHCP.

## Usage

```bash
terraform apply -var="static_ip=10.x.x.100"
```

## Important

- The IP must be within your allocated subnet range
- The IP must not already be in use
- Contact ASI Support for your available IP range
