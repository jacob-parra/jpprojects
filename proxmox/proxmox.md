---
title: Proxmox
layout: default
---

## Proxmox Virtual Environment

Proxmox is an opensource, enterprise grade server management platform for virtualization (essentially a very good hypervisor). It can be run locally and is free for personal use. It stands out among other hypervisors for screenshot and backup capabilities and smooth networking.

This was the most ambitious of my projects so far but it provides the infrastructure to grow my lab in a stable, standard manner. These are the steps I followed to install and setup my Proxmox VE server.

<hr>

#### 1. Prepare the hardware

Having a dedicated proxmox server prevents your services, servers and virtual machines prevents your main desktop for being bogged down by resource greedy processes. When selecting hardware, keep in mind that Proxmox VE requires very few resources: 

- 64 bit CPU with virtualization support (Intel VT or AMD-V)
- 2 GB of Ram (though 16 is reccommend for a few machines. More Ram, more VMs)
- 32 GB of storage (for the OS and the VMs. An SSD, at least for proxmox itself, is preffered for fast booting)

I would recommend buying a workstation desktop off of Ebay or Facebook Marketplace. These machines often have plenty of resources and are not very expensive (from $100-$150). Mini PCs can also work, use even less energy, take less space and cost lest money.

<div class="info">
In terms of hardware, this project will also need a USB drive. USB Type A is the preffered type. You also need a keyboard, as well as a monitor for initial setup.
</div>

#### 2. Modify the BIOS

The BIOS needs certain settings in order to support virtualization. You can access the BIOS by spamming the DEL key while booting the host. While the exact settings may vary between CPUs and manufacturer, these are the basic settings that should be checked:

- Check "Virtualization Support", and make sure your CPU virtualization support is enabled
- Enable "UEFI" in the Boot List Options (Proxmox runs better in UEFI compared to "Legacy")
- Disable Secure Boot (it can cause issues with Proxmox)
- Check that Sata Operation is in AHCI mode, NOT RAID (proxmox expects direct disk access).

Be sure to hit "Apply" before exiting the BIOS

#### 3. Download the ProxmoxVE ISO

This can be found on the Proxmox website. I used version <a href="https://proxmox.com/en/downloads">9.1</a>. Download "Proxmox VE 9.1 ISO Installer". 

#### 4. Flash the ISO to a bootable drive

The installer needs to be flashed to a USB drive, which will later be used to put Proxmox on the machine. I used <a href="https://etcher.balena.io/#download-etcher">Balena Etcher</a> on my Mac and I believe it works on Windows too. 

Using Balena is very straightforward. Upon opening the app click "Flash from file" and select the Proxmox ISO installer. Insert your USB Drive, click "Select Target" and select your USB drive. Then click "Flash". Mac or Windows may ask for your password, neccessary to write to a drive.

#### 5. One-Time Boot and Install

Once the bootable USB is made, plug it in to the proxmox machine (prefferably in a rear port), along with a keyboard. Boot (or restart) the machine, and repeatedly press F12 (or F2, or Del, or Esc or F11. It depends between different machines. Look it up if needed) to enter the boot menu. Select your USB and press Enter. This will bring up the Proxmox Installer screen.

- Choose Install Proxmox VE (the first option) and press Enter.

- Agree to the license statement.

- Select your SSD or Hard drive...

<div class="info">
Note: THE SELECTED DRIVE WILL BE WIPED
</div>

- On the same screen, click "Options" and set the filesystem to "ext4". Click "OK" and then "Next".

- Set your location and time. Click "Next".

- Set a root password. Dont forget it! Set an email too (it is used for alerts. Can be fake if desired). Click "Next".

- This is where things get a little tricky. Make sure the management interface is correctly using your machines NIC (nic0 or eno1 or enp0s25). Set a host name (i.e. proxmox.local). Set the IP Address, Gateway and DNS Server. I recommend using your router IP address as the gateway, as well as setting an IP address that is not in your routers DHCP range. Something like 192.168.x.x is good. 1.1.1.1 (Cloudflare) and 8.8.8.8 (Google) are good DNS Servers (PiHole can also be used for DNS). Click "Next".

Review the summary (I suggest taking a picture) and click "Install". The installation may take several minutes

#### 6. Access the GUI

After installing, a black terminal will show the ip address and port where the GUI is available. Use another machine on the LAN and access the GUI via a browser at the shown address (i.e. visit 192.168.x.x:8006). Log in with the `root` user and password set in the previous step.

A warning will pop up reminding you that you do not have an eterprise license. Just hit ok, it doesn't matter and is not necessary, but supporting opensource projects is cool.

#### 7. Access the Terminal locally (and over SSH)

Back on the proxmox server, login with `root` user and password. This is a terminal as usual.

Proxmox comes with the standard OpenSSH server. SSH in with `root@192.168.x.x` from another computer on the LAN for remote access.

#### 8. Stop using the Enterprise Repo

This is necessary before updating or installing apps. The exact steps vary between versions so some extra googling may be necessary.

- Run `mv /etc/apt/sources.list.d/pve-enterprise.sources /etc/apt/sources.list.d pve-enterprise.sources.disabled` or 
`mv /etc/apt/sources.list.d/ceph.sources /etc/apt/sources.list.d/ceph.sources.disabled`. This renames the enterprise repo file, effectively removing Proxmox Access to it and preventing unallowed IPs from being blocked.
- Create the non-enterprise repo file with `nano /etc/apt/sources.list.d/pve-no-subscription.list`. Put `deb http://download.proxmox.com/debian/pve trixie pve-no-subscription` in there.

#### 9. Create VMs

Visit the [Proxmox Hub](/jpprojects/proxmox/proxmoxhub) to see documentation for a variety of VMs.
