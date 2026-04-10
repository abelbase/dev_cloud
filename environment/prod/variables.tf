variable "rg_location" {
  type = string
}
variable "rg_name" {
  type = string
}
variable "app_name" {
  type = string
}

variable "tags" {
  type = object({
    env          = string
    app_name     = string
    created_date = string
  })
}
variable "vnet_name" {
  type = string
}
variable "vnet_address" {
  type = list(string)
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