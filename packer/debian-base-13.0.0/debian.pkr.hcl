packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}



source "proxmox-iso" "debian-base" {
  proxmox_url         = var.proxmox_api_url
  username            = var.proxmox_api_token_id
  token               = var.proxmox_api_token_secret
  node                = "pve"
  vm_name             = "debian-base-template"
  vm_id               = local.vm_id
  insecure_skip_tls_verify = true 
  boot_iso {
    iso_file         = "local:iso/debian-13.0.0-amd64-netinst.iso"
    iso_storage_pool = "local"
    unmount          = true
  }
  template_name       = local.template_name
  template_description = "Debian 13 base image"
  http_directory      = "http"
  boot_wait           = "10s"
  boot_command        = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"
  ]
  qemu_agent          = true
  memory              = 2048
  cores               = 2
  cpu_type            = "kvm64"
  os                  = "l26"
  disks {
    type              = "scsi"
    disk_size         = "20G"
    storage_pool      = "local-lvm"
    format            = "raw"
  }
  network_adapters {
    model             = "virtio"
    bridge            = "vmbr0"
  }
  ssh_username        = "root"
  ssh_password        = "packer"
  ssh_private_key_file = "/home/carnellj/.ssh/id_rsa"
  ssh_timeout         = "15m"

}

build {
  sources = ["source.proxmox-iso.debian-base"]

  provisioner "shell" {
    inline = [
      # Ensure SSH is running and enabled
      "systemctl enable ssh",
      "systemctl start ssh",
      # Restart SSH to ensure configuration is applied
      "systemctl restart ssh",
      # Debugging SSH status
    ]
  }

  provisioner "file" {
    source = "/home/carnellj/.ssh/id_rsa.pub"
    destination = "/tmp/authorized_keys"
  }

  provisioner "shell" {
    inline = [
      "mkdir -p /root/.ssh",
      "chmod 700 /root/.ssh",
      "mv /tmp/authorized_keys /root/.ssh/",
      "chmod 600 /root/.ssh/authorized_keys",
      "apt-get clean",
      "rm -rf /var/lib/apt/lists/*",
      "rm -f /root/.bash_history"
    ]
  }
}