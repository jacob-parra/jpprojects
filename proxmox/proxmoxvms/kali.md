---
title: Kali
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">
<img src="/jpprojects/images/images/kali.png" class="float_img" alt="Kali">

## Kali

These are the steps for configuring a Kali Virtual Machine

#### 1. Download the Kali ISO

Download <a href="https://ubuntu.com/download/server">here</a>.

#### 2. Upload the ISO to Proxmox

- Access the Proxmox Web UI
- Click on your node (on the left side, under "Datacenter")
- Select the "local" storage option
- Go to "ISO Images"
- Click "Upload" on the top left
- Select the Ubuntu ISO from the last step
- Wait for the upload to complete, then close the upload window

Make sure you see the iso listed 

#### 3. Create the VM
This has a lot of steps, but there is *some* room for error. These configurations are organized by section/tab:

- General
    - Leave the default VM ID
    - Set a name (something like ubuntu-01)
    - Click "Next"
- OS
    - ISO Image: select the Ubuntu ISO
    - Keep "Guest OS" as "Linux"
    - Version: 6.x - 2.6 Kernel
    - Click "Next"
- System
    - BIOS : SeaBIOS (Kali does not need UEFI and it caused issues for me)
    - Add EFI disk : Checked
    - SCSI Controller: VirtIO SCSI single
    - QEMU Agent: Checked
    - TPM : Not checked (don't need it)
    - Keep the other defaults
    - Click "Next"
- Disks
    - Bus/Device : SCSI
    - Storage : local-lvm (or whatever is available)
    - Disk size : 32 GB (Minimum 20 GB, 40 GB recommended)
    - Cache : Default
    - Discard : Check the box
    - Click "Next"
- CPU
    - Cores : 2
    - Type : host (scroll down, it's probably on the bottom)
- Memory
    - Keep 2048 (it's listed in MiB)
    - Click "Next"
- Network
    - Bridge: vmbr0
    - Model: VirtIO (paravirtualized)
    - Click "Next"
- Confirm
    - Make sure everything is right
    - Check the "Start after created" box if you want
    - Click Finish

#### 4. Install Kali

Click on the VM (listed by id) on the left bar, then click "Console". Click the "Start Now" power button in the middle. 

As it boots up, it will send you through an installation process. Follow these configuration steps and then restart the VM

- Select your language
- Select your country
- Select your keyboard
- Machine name (something like `kalivm`)
- Domain : Probably leave blank, unless you know what you are doing with that
- Set user name, and username.
- Set password
- Set time zone
- Select "Guided - Use entire disk"
- Select default disk
- Then "All files in one partition"
- Review disk partitions and continue
- Partition disks --> Write changes to disk --> yes
- Leave Desktop kali, xfce, and install top tools (should all be default) enabled.
- Install the GRUB boot loader

Let the VM reboot, and quickly move to step 5

#### 5. Remove the ISO

- If the VM has already finished rebooting, shut off the VM
- Go to Hardware, click the CD/DVD Drive and click "Remove" on the top menu
- Restart the VM and wait for it to boot

#### 6. Login and finish configurations

Login with the name and password set in step 4.

<hr>

#### 7. Install the QEMU Guest Agent

See the [Proxmox Scripting project page](/jpprojects/proxmox/scripting), step 2, for instructions on how to do this.

#### 8. Install OpenSSH

See [OpenSSH project page](/jpprojects/proxmox/openssh) for instructions on how to do this.