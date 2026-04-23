# My Terraform Module

Short description of what this module does and where it should be used.

## Example usage

```hcl
module "my_vnet" {
  source        = "./modules/vnet"
  vnet_name     = "landingZoneHUB"
  address_space = ["10.0.0.0/16"]
}
```

## Requirements

- Terraform >= 1.3.0
- Provider `azurerm` >= 4.68.0

## Providers

- azurerm

## Variables

See table below (or describe key ones if you don’t auto‑generate).

## Outputs

- `vnet_detials` - Virtual network name and id.


