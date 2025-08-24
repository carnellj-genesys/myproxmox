
provider "proxmox" {
  pm_api_url                  = var.proxmox_api_url
  pm_tls_insecure             = true # By default Proxmox Virtual Environment uses self-signed certificates.
  pm_api_token_id             = var.proxmox_api_username
  pm_api_token_secret         = var.proxmox_api_usertoken
  pm_log_enable               = true
  pm_minimum_permission_check = false #This is workaround so the provider does not try to check permissions
}

resource "proxmox_vm_qemu" "myserver" {
  name        = "myexampleserver"
  target_node = "pve"
  clone       = "debian-13-base-20250814012024"
  full_clone  = true
  bios        = "seabios"

  agent   = 1

  memory  = 2048
  scsihw  = "lsi"
  os_type = "linux"

  boot = "order=scsi0"

  cpu {
    cores = 2
    sockets = 1
  }

  network {
    id        = 0
    model     = "virtio"
    bridge    = "vmbr0"
    link_down = false
    firewall  = false
  }

  disks {
    scsi {
      scsi0 {
        disk {
          size    = "20G"
          storage = "local-lvm"
          format  = "raw"
        }
      }
    }
  }

  connection {
    type     = "ssh"
    user     = var.vm_ssh_user
    password = var.vm_ssh_password
    host     = self.ssh_host
  }

  provisioner "file" {
    source      = local_file.bootstrap_file.filename
    destination = "/root/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = ["chmod +x /root/bootstrap.sh", 
              "/root/bootstrap.sh"]
  }

}

# # Modify path for templatefile and use the recommended extension of .tftpl for syntax hylighting in code editors.
resource "local_file" "bootstrap_file" {
  content  = templatefile("bootstrap.sh.tftpl", {})
  filename = "bootstrap.sh"
}