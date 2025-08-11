# Example: Web Server VM Configuration
# This file shows how to deploy a web server VM with custom configuration

# Use the same provider configuration as main.tf
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
  endpoint = "https://192.168.1.101:8006/api2/json"
  username = "your_username@pve"
  password = "your_password"
  insecure = true
  ssh {
    agent    = true
    username = "root"
  }
}

# Data source to find the Debian base template
data "proxmox_virtual_environment_vm" "debian_template" {
  node_name = "pve"
  vm_id     = 9000  # Update this to match your template VM ID
}

# Create a web server VM
resource "proxmox_virtual_environment_vm" "web_server" {
  name        = "web-server-01"
  node_name   = "pve"
  vm_id       = 1001
  description = "Web server for production applications"

  # Clone from the template
  clone {
    vm_id = data.proxmox_virtual_environment_vm.debian_template.id
    full  = true
  }

  # CPU configuration - more resources for web server
  cpu {
    cores = 4
    type  = "kvm64"
  }

  # Memory configuration - increased for web applications
  memory {
    dedicated = 8192  # 8GB RAM
  }

  # Disk configuration - larger disk for web content
  disk {
    datastore_id = "local-lvm"
    file_id      = "debian-base-template/web-server-01/vm-1001-disk-0.raw"
    size         = 50  # 50GB disk
    interface    = "scsi0"
  }

  # Network configuration
  network_device {
    bridge = "vmbr0"
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

  # Tags for organization
  tags = ["debian", "terraform", "web-server", "production"]

  # Lifecycle configuration
  lifecycle {
    create_before_destroy = true
  }
}

# Output the web server information
output "web_server_info" {
  description = "Information about the web server VM"
  value = {
    id       = proxmox_virtual_environment_vm.web_server.id
    name     = proxmox_virtual_environment_vm.web_server.name
    node     = proxmox_virtual_environment_vm.web_server.node_name
    ip       = proxmox_virtual_environment_vm.web_server.ipv4_addresses
    status   = proxmox_virtual_environment_vm.web_server.status
  }
}

# Example: Install web server software after VM creation
resource "null_resource" "web_server_provisioning" {
  depends_on = [proxmox_virtual_environment_vm.web_server]
  
  connection {
    host     = proxmox_virtual_environment_vm.web_server.ipv4_addresses[0]
    user     = "root"
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update",
      "apt-get install -y nginx apache2-utils",
      "systemctl enable nginx",
      "systemctl start nginx",
      "echo 'Web server is ready!' > /var/www/html/index.html"
    ]
  }
} 