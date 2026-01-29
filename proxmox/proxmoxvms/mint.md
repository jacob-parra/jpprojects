---
title: Mint
layout: default
---

## Mint

Ubuntu is one of the friendliest distros for people new to Linux. It's widely supported with a large community. It boeasts a slick GUI and reliable stability.

These are the steps for configuring an Ubuntu Virtual Machine

**1. Download the Ubuntu ISO**

Download <a href="https://ubuntu.com/download/server">here</a>.

**2. Upload the ISO to Proxmox**

- Access the Proxmox Web UI
- Click on your node (on the left side, under "Datacenter")
- Select the "local" storage option
- Go to "ISO Images"
- Click "Upload" on the top left
- Select the Ubuntu ISO from the last step
- Wait for the upload to complete, then close the upload window

Make sure you see the iso listed.

**3. Create the VM**
This has a lot of steps, but there is *some* room for error. These configurations are organized by section/tab:

- General
    - Leave the default VM ID
    - Set a name (something like mint-01)
    - Click "Next"
- OS
    - ISO Image: select the Mint ISO
    - Keep "Guest OS" as "Linux"
    - Version: 6.x - 2.6 Kernal
    - Click "Next"
- System
    - BIOS : OVMF (UEFI)
    - Machine : q35
    - SCSI Controller: VirtIO SCSI
    - QEMU Guest Agent: Checked
    - Click "Next"
- Disks
    - Bus/Device : VirtIO Block
    - Storage : local-lvm (or whatever is available)
    - Disk size : 32 GB minimum, suggested 40 GB +
    - Discard : Check the box
    - Click "Next"
- CPU
    - Cores : 2
    - Type : host (scroll down, it's probably on the bottom)
- Memory
    - Set 4096 (it's listed in MiB)
    - Click "Next"
- Network
    - Bridge: vmbr0
    - Model: VirtIO (paravirtualized)
    - Click "Next"
- Confirm
    - Make sure everything is right
    - Check the "Start after created" box
    - Click Finish

**4. Install Mint**

Click on the VM (listed by id) on the left bar, then click "Console". Click the "Start Now" power button in the middle. 

As it boots up, it will send you through an installation process. Follow these configuration steps and then restart the VM

- Press enter on the first option
- As Mint loads to the desktop, locate and open the "Install Linux Mint" cd icon. This opens the installation process.
- Select your keyboard and language.
- I chose not to install multimedia codecs. If needed, those can be installed later.
- Keep the default "Erase disk and install Linux Mint" option. Click "Install Now", and continue to "Write the changes to disks".
- Select your time zone
- Set your name, computer name, username and password
- Wait for the installation to finish (it can take a while)

**5. Remove the ISO**

When the installation finishes and restarts, it will show a black screen instructing you to remove the ISO. To do so, click on "Hardware" on the left menu of the VM. Click "CD/DVD" in the list, and click "Remove" on the top. Select "Confirm".

This keeps the machine from reinstalling Ubuntu over and over again. Navigate back to the 
"Console" section of the VM and press "Enter" as instructed.

**6. Login and finish configurations**

Login with the name and password set in step 4. Make the following selections when prompted:

Walk through the First Steps and launch configuration applications as desired (I recommend checking out Desktop Colors and System Settings)

You can remove the boot disk used in step 4, if it is still on the desktop, by right clicking and selecting "eject".

<hr>

**7. Install the QEMU Guest Agent**

See the [Proxmox Scripting project page](/jpprojects/proxmox/scripting), step 2, for instructions on how to do this.

**8. Install OpenSSH**

See [OpenSSH project page](/jpprojects/proxmox/openssh) for instructions on how to do this.