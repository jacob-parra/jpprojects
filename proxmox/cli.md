---
title: CLI
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">

## Managing VMs/Containers from the Command Line

This is a list of commands to use from the CLI of the Proxmox host to be able to control VMs, in case you are not able to access the Proxmox Web Console.

#### List all VMs

`qm list`

- This will show all vms by host name and **VMID**, as well as their status.

#### State Commands

`qm start <vmid>`

- Start a VM.

`qm stop <vmid>`

- This immediatly kills a VM, like removing a power cord. Be careful with this one.

`qm shutdown <vmid>`

- Sends an ACPI shutdown signal to turn off gracefully.

`qm reboot <vmid>`

- Sends a graceful shutdown signal and then a start signal.

`qm suspend <vmid>`

- Pause a VM.

`qm resume <vmid>`

- Resume.

#### Configuration

`qm create <vmid> [options]`

- Create a VM with an id number and options.

`qm set <vmid> [options]`

- Modify a VM options in place.

`qm destroy <vmid>`

- Delete a machine.

#### Access

`qm monitor <vmid>`

- Connect to the terminal of the VM.

`qm guest exec <vmid> <command> [arguments]`

- Execute commands on the VMs terminal.