terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50.0"
    }
  }
}

# Configure the Proxmox Provider
provider "proxmox" {
  endpoint = var.proxmox_api_url
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true
  ssh {
    agent    = true
    username = "root"
  }
}

# Data source to find the latest Debian base template
data "proxmox_virtual_environment_vm" "debian_template" {
  node_name = var.proxmox_node
  vm_id     = var.template_vm_id
}

# Create a VM from the template
resource "proxmox_virtual_environment_vm" "debian_vm" {
  name        = var.vm_name
  node_name   = var.proxmox_node
  vm_id       = var.vm_id
  description = var.vm_description

  # Clone from the template
  clone {
    vm_id = data.proxmox_virtual_environment_vm.debian_template.id
    full  = true
  }

  # CPU configuration
  cpu {
    cores = var.vm_cpu_cores
    type  = var.vm_cpu_type
  }

  # Memory configuration
  memory {
    dedicated = var.vm_memory
  }

  # Disk configuration
  disk {
    datastore_id = var.vm_disk_datastore
    file_id      = "debian-base-template/${var.vm_name}/vm-${var.vm_id}-disk-0.raw"
    size         = var.vm_disk_size
    interface    = "scsi0"
  }

  # Network configuration
  network_device {
    bridge = var.vm_network_bridge
    model  = "virtio"
  }

  # Agent configuration
  agent {
    enabled = true
  }

  # Operating system configuration
  operating_system {
    type = "l26"
  }

  # Lifecycle configuration
  lifecycle {
    create_before_destroy = true
  }

  # Tags for organization
  tags = var.vm_tags
}

# Output the VM information
output "vm_info" {
  description = "Information about the created VM"
  value = {
    id       = proxmox_virtual_environment_vm.debian_vm.id
    name     = proxmox_virtual_environment_vm.debian_vm.name
    node     = proxmox_virtual_environment_vm.debian_vm.node_name
    ip       = proxmox_virtual_environment_vm.debian_vm.ipv4_addresses
    status   = proxmox_virtual_environment_vm.debian_vm.status
  }
} 