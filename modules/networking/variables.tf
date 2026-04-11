variable "vnet_name" {
  type = string
}
variable "app_name" {
  type = string
}
variable "rg" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
  validation {
    condition     = alltrue([for ip in var.vnet_address_space : can(cidrhost(ip, 0))])
    error_message = "ip address not in format..."
  }
}

variable "tags" {
  type = object({
    env          = string
    app_name     = string
    created_date = string
    created_by   = optional(string, "terraform")
  })
}
variable "subnet_details" {
  type = map(object({
    address_prefixes = optional(list(string), [])
  }))
  default = {}
}

variable "nsg_details" {
  type = map(object({
    nsg_name    = string
    subnet_name = string
    rule        = optional(map(map(string)), {})
  }))
  default = {}
}