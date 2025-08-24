# Proxmox connection variables
variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
 }

variable "proxmox_api_username" {
  description = "Proxmox API ID"
  type        = string
  sensitive   = true
}

variable "proxmox_api_usertoken" {
  description = "Proxmox usertoken"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}


# VM configuration
variable "vm_name" {
  description = "Name of the VM to create"
  type        = string
  default     = "debian-vm"
}


variable "vm_description" {
  description = "Description of the VM"
  type        = string
  default     = "Debian VM created from base template"
}

variable "vm_cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_cpu_type" {
  description = "CPU type"
  type        = string
  default     = "kvm64"
}

variable "vm_memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

variable "vm_disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "vm_disk_datastore" {
  description = "Datastore for the VM disk"
  type        = string
  default     = "local-lvm"
}

variable "vm_network_bridge" {
  description = "Network bridge to use"
  type        = string
  default     = "vmbr0"
}

variable "vm_tags" {
  description = "Tags to apply to the VM"
  type        = list(string)
  default     = ["debian", "terraform", "template"]
} 

variable "vm_ssh_user" {
  description = "SSH user"
  type        = string

}

variable "vm_ssh_password" {
  description = "SSH password"
  type        = string
}

