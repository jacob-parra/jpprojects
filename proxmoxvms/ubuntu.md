---
title: Github Pages
layout: default
---

## Ubuntu

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

Make sure you see the iso listed 

**3. Create the VM**
This has a lot of steps, but there is *some* room for error. These configurations are organized by section/tab:

- General
    - Leave the default VM ID
    - Set a name (something like ubuntu-01)
    - Click "Next"
- OS
    - ISO Image: select the Ubuntu ISO
    - Keep "Guest OS" as "Linux"
    - Version: Ubuntu (or "other" if listed. Niether option appeared for me, so I left the default)
    - Click "Next"
- System
    - BIOS : OVMF (UEFI)
    - Machine : q35
    - Keep the other defaults
    - Click "Next"
- Disks
    - Bus/Device : VirtIO Block
    - Storage : local-lvm (or whatever is available)
    - Disk size : 32 GB
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
    - Check the "Start after created" box
    - Click Finish

**4. Install Ubuntu**

Click on the VM (listed by id) on the left bar, then click "Console". Click the "Start Now" power button in the middle. 

As it boots up, it will send you through an installation process. Follow these configuration steps and then restart the VM

- Press "Enter" on first available option
- Install Ubuntu
- Set language and keyboard
- Select "Minimal installation" and "Download updates while installing Ubuntu"
- Select "Erase disk and install ubuntu"
- Select your time zone
- Set the name, computer name, username and password for the machine
- Wait for the installation to complete

**5. Remove the ISO**

When the installation finishes and restarts, it will show a black screen instructing you to remove the ISO. To do so, click on "Hardware" on the left menu of the VM. Click "CD/DVD" in the list, and click "Remove" on the top. Select "Confirm".

This keeps the machine from reinstalling Ubuntu over and over again. Navigate back to the 
"Console" section of the VM and press "Enter" as instructed.

**6. Login and finish configurations**

Login with the name and password set in step 4. Make the following selections when prompted:

- Skip ubuntu pro
- Dont send system info
- Keep location services off
- upgrade if asked. Ubuntu may need to restart.

**7. Install OpenSSH**

OpenSSH is a simple way to enable SSH capabilities on the virtual machine. These commands can be run from the terminal, which can be accessed by right clicking on the Ubuntu desktop and clicking "Open in Terminal" in the menu. 

- Run `sudo apt update` to make sure everything is up to date
- Install with `sudo apt install -y openssh-server`
- Check the status with `sudo systemctl status ssh`. It should already be running. If not, do `sudo systemctl enable --now ssh`.
