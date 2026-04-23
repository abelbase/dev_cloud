variable "aks_config" {
  type = object({
    aks_name            = optional(string, null)
    location            = optional(string, null)
    resource_group_name = optional(string, null)
    dns_prefix          = optional(string, null)
    default_node_pool   = optional(map(string), {})
  })
  default = {}
}
variable "tags" {
  type = map(any)

}
variable "acr_config" {
  type = object({
    name                = optional(string, null)
    resource_group_name = optional(string, null)
    location            = optional(string, null)
    sku                 = optional(string, "Standard")
    role_assingment     = optional(string, null)
  })
  default = null
}

