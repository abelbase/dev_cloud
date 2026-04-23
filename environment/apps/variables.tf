variable "rg" {
  description = "Resource group name"
  type        = list(string)

}
variable "tags" {
  description = "tags for resources"
  type = map(object({
    dept = string
    env  = string
    team = string
  }))
}
variable "vnet_detials" {
  description = "Virtual network details with subnet and nsg"
  type = map(object({
    rg           = string
    vnet_address = list(string)
    subnet_details = map(object({
      address_prefixes = list(string)
    }))
    nsg_details = map(object({
      nsg_name    = string
      subnet_name = string
      all_rule    = list(string)
      rule        = optional(map(map(string)), {})
    }))
  }))
}
variable "subs_id" {
  type = string
}