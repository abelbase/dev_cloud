variable "rg_config" {
  type = map(object({
    name = string
    tags = object({
      dept = string
      env  = string
      team = string
    })
  }))
  default = {}
  validation {
    condition = alltrue([
      for key, value in var.rg_config :
      can(regex("^[a-zA-Z0-9]+$", value.name)) &&
      can(regex("^[a-zA-Z0-9]+$", value.tags.dept)) &&
      can(regex("^[a-zA-Z0-9]+$", value.tags.env)) &&
      can(regex("^[a-zA-Z0-9]+$", value.tags.team))

    ])
    error_message = "something went wrong"
  }
}
// variable "tags" {
//   type = object({
//     dept         = string
//     team         = string
//     env          = string
//   })
// }
variable "policy_set_config" {
  type = map(object({
    name           = string
    policy_type    = string
    display_name   = string
    set_definition = list(string)
  }))
}
variable "vnet_name" {
  type = string
}
variable "vnet_address_space" {
  type = list(string)
}
variable "subnet_details" {
  type = map(object({
    address_prefixes = list(string)
  }))
}
variable "nsg_details" {
  type = map(object({
    nsg_name    = string
    subnet_name = string
    all_rule    = list(string)
    rule        = any
  }))
}
variable "nat_gateway_name" {
  type = string
}
variable "tags" {
  type = object({
    dept = string
    team = string
    env  = string
  })
}
variable "subs_id" {
  type = string
}