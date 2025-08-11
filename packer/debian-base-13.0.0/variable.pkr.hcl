# Variable Definitions
variable "proxmox_api_url" {
  type    = string
  default = "https://192.168.1.101:8006/api2/json"
}

variable "proxmox_api_token_id" {
  type    = string
  default = env("PROX_MOX_CLIENT_ID")
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
  default   = env("PROX_MOX_TOKEN")
}

# Local variables
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  template_name = "debian-13-base-${local.timestamp}"
  vm_id = 9000 + parseint(regex_replace(timestamp(), "[- TZ:]", ""), 10) % 1000
}