variable "policy_config" {
  type = any
}
variable "policy_set_config" {
  type = map(object({
    name           = string
    policy_type    = string
    display_name   = string
    set_definition = list(string)
  }))

}