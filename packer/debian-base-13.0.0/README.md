# Debian Base Template Builder

This directory contains Packer configuration files to automatically build a Debian 13 base template for Proxmox VE.

## Overview

This Packer configuration creates a standardized Debian 13 base image that can be used as a template for deploying new VMs in your Proxmox environment. The template includes:

- Debian 13.0.0 minimal installation
- SSH server enabled and configured
- Your SSH public key installed for secure access
- Cleaned up package cache and temporary files
- Optimized for cloning and deployment

## Files

- **`debian.pkr.hcl`** - Main Packer configuration file
- **`variable.pkr.hcl`** - Variable definitions and local values
- **`http/preseed.cfg`** - Automated installation configuration for Debian
- **`README.md`** - This documentation file

## Prerequisites

1. **Packer installed** - Version 1.8.0 or later
2. **Proxmox VE access** - API access to your Proxmox cluster
3. **ISO file** - Debian 13.0.0 netinst ISO uploaded to your Proxmox storage
4. **SSH key pair** - Your SSH public/private key pair

## Configuration

### Environment Variables

Before running Packer, you must set these environment variables:

```bash
export PROX_MOX_CLIENT_ID="username@realm!token_name"
export PROX_MOX_TOKEN="your_api_token_secret"
```

**Example:**
```bash
export PROX_MOX_CLIENT_ID="packer@pve!packer-token"
export PROX_MOX_TOKEN="abc123-def456-ghi789"
```

### Proxmox Configuration

The configuration connects to your Proxmox cluster at:
- **URL**: `https://192.168.1.101:8006/api2/json`
- **Node**: `pve`
- **Storage**: `local-lvm` for disk, `local` for ISO

**Note**: Update the IP address in `variable.pkr.hcl` if your Proxmox server has a different IP.

### VM Specifications

- **Memory**: 2GB RAM
- **CPU**: 2 cores, KVM64 type
- **Disk**: 20GB SCSI disk in raw format
- **Network**: VirtIO adapter on vmbr0 bridge
- **VM ID**: Automatically generated (9000 + timestamp-based offset)

## How to Run

### 1. Set Environment Variables

```bash
export PROX_MOX_CLIENT_ID="your_client_id"
export PROX_MOX_TOKEN="your_token"
```

### 2. Verify ISO File

Ensure the Debian 13.0.0 ISO is uploaded to your Proxmox storage at:
```
local:iso/debian-13.0.0-amd64-netinst.iso
```

### 3. Run Packer Build

```bash
cd packer/debian-base-13.0.0
packer build .
```

### 4. Monitor Progress

Packer will:
1. Create a new VM in Proxmox
2. Boot from the Debian ISO
3. Automatically install Debian using the preseed configuration
4. Configure SSH and install your public key
5. Clean up temporary files
6. Convert the VM to a template

## What Gets Created

- **Template Name**: `debian-13-base-{timestamp}`
- **VM ID**: Dynamic (9000 + offset)
- **Storage**: 20GB disk on local-lvm storage pool
- **Network**: Configured with vmbr0 bridge

## Troubleshooting

### Common Issues

1. **"username must be specified"**
   - Ensure `PROX_MOX_CLIENT_ID` environment variable is set
   - Check that the variable contains a valid Proxmox API token ID

2. **"token must be specified"**
   - Ensure `PROX_MOX_TOKEN` environment variable is set
   - Verify the token has sufficient permissions

3. **ISO not found**
   - Upload the Debian 13.0.0 ISO to your Proxmox storage
   - Verify the path in the configuration matches your storage setup

4. **SSH connection failed**
   - Check that your SSH private key path is correct
   - Ensure the VM can reach your network

### Debug Mode

Run Packer with debug logging:
```bash
PACKER_LOG=1 packer build .
```

## Security Notes

- The template includes your SSH public key for secure access
- API tokens should have minimal required permissions
- Consider using environment-specific token files for production
- The preseed configuration creates a root user with password "packer" (change this in production)

## Customization

### Modify VM Specifications

Edit `debian.pkr.hcl` to change:
- Memory allocation
- CPU cores
- Disk size
- Network configuration

### Update Preseed Configuration

Modify `http/preseed.cfg` to:
- Change default packages
- Modify user creation
- Adjust partitioning
- Configure additional services

### Add Provisioners

Add more provisioners in the build section to:
- Install additional software
- Configure services
- Apply security policies
- Set up monitoring

## Next Steps

After creating the template:
1. Clone the template to create new VMs
2. Customize the cloned VMs for specific use cases
3. Consider creating additional templates for different purposes (web servers, databases, etc.)
4. Automate template updates with CI/CD pipelines 