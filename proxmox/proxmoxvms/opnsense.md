---
title: OPNsense
layout: default
---

## OPNsense

Opensense is a robust, open-source router software platform. It began as a fork of pfSense and m0n0wall and is generally considered more user friendly. Setting up a virtual router is not exactly trivial, but if you are careful it can be done.

These are the steps for configuring an OPNsense VM in Proxmox.

<div class="info">
One of the parts that makes this tricky is the fact that routing, naturally, requires two network ports: one for the LAN side, one for the WAN side. If your Proxmox host server does not have 2 ports, you have a few options. Adding a new network card can be expensive depending on the host hardware, so a much cheaper, albeit less ideal option, is to buy an RJ45 to USB adapter to act as the second network interface. I used <a href="amazon.com/dp/B09GRL3VCN ref=ppx_yo2ov_dt_b_fed_asin_title">this one</a> from TP-Link: it's cheap and works reliably with Linux systems (which Proxmox is). This page will be written with this strategy in mind.
</div>
<br>
<div class="info">
This is a very networking heavy project. One way to reduce headaches later is to solidify your network topology now. For sake of simplicity, I put all of my machines on a single subnet before starting (i.e. 192.168.10.x/24). This will be your LAN subnet. Machines and services not explicetly assigned an IP address within that range will be assigned one via DHCP, which may affect your ability to connect to them later. It's worth the investment to get your ducks in a row now. Quack.
</div>

**1. Download the OPNsense ISO** 

Download <a href="https://opnsense.org/download/">here</a>. Be sure to download the AMD64, VGA installer. 

It will probably download as very specific `.iso.bz2` format (compressed). I used 7-zip on Windows to export it properly. You can download 7-zip <a href="https://www.7-zip.org/download.html">here</a>. Just grab the .exe version. When extracted properly, the file will have a .iso extension.

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

This are the settings I used, organized by section/tab:


- General
    - Leave the default VM ID
    - Set a name (something like opnsense.)
    - Click "Next"
- OS
    - ISO Image: select the opnsense ISO
    - Set "Guest OS" as "Other"
    - Version: 6.x - 2.6 Kernal, if the option is there
    - Click "Next"
- System
    - BIOS : OVMF (UEFI)
    - Machine : q35
    - SCSI Controller: VirtIO SCSI
    - QEMU Guest Agent: Checked
    - Add EFI Disk: Yes
    - Click "Next"
- Disks
    - Bus/Device : VirtIO Block
    - Storage : local-lvm (or whatever is available)
    - Disk size : 32 GB is fine.
    - Click "Next"
- CPU
    - Cores : 2 (at least. If your host has more and you'll be sending lots of encrypted traffic, more cores can preserve bandwidth)
    - Type : host (scroll down, it's probably on the bottom)
- Memory
    - Set 4096 (you could get by with 2 GB if needed)(it's listed in MiB)
    - Click "Next"
- Network : These settings are going to be added to later, as we will need to add a second bridge.
    - Bridge: vmbr0
    - Model: VirtIO (paravirtualized)
    - Click "Next"
- Confirm
    - Make sure everything is right
    - Click Finish

**4. Install the ISO in the VM**

Before installing, OPNsense can be run "live" (live media mode), where configurations won't save between reboots. 

After the machine boots up and you log in, there will be a menu with several numbered options. Pick option `8` to access the shell. Run `opnsense-installer` or `Installer` to enter the install menu.

When prompted for the Keymap, keep the defualt by pressing Enter. On the Filesystem menu, I had to use `UFS` (`ZFS` may be an option on your hardware). Then select the only available disk, confirm the install and let it finish.

When it finishes and reboots you should be able to log in as `root` with `opnsense` as the password.

**5. Prepare the Bridges**

The router is going to be connecting internal (LAN) traffic to the outside internet (WAN). Physically, this will require our Proxmox host to have 2 NICs. Virtually, these NICs will each be configured as a VM Bridge (vmbr). 2 NICs means 2 vmbr.

This is the configuration I used for my setup:

1. In the Proxmox Host Console, run `nano /etc/network/interfaces`
2. Add this in there:

```
# loopback
auto lo
iface lo inet loopback

# LAN bridge (built-in NIC)
auto vmbr0
iface vmbr0 inet static
    address 192.168.10.2/24 # the IP address of Proxmox
    bridge-ports enp1s0     # your built-in NIC
    bridge-stp off
    bridge-fd 0
    gateway 192.168.10.1    # OPNsense LAN as default route

# WAN bridge (USB NIC)
auto vmbr1
iface vmbr1 inet manual
    bridge-ports enxXXXX     # your USB NIC
    bridge-stp off
    bridge-fd 0
```

A couple of things to note here:
1. vmbr0 is the internal bridge (LAN), vmbr1 is the external bridge (WAN).
2. The LAN address needs to be on the same subnet as the rest of your LAN (192.168.10.x/24 in my example).
3. The gateway for the LAN side is the IP address we are going to assign to the OPNsense VM.
4. You put the name of the USB NIC into the birdge-ports option of vmbr1. This is usually the devices MAC address, which can be found by running `ip a` in the Proxmox host console while it is plugged in. It will likely be the only device listed with a MAC address as the interface name

3. Save and close the file. Restart networking with `systemctl restart networking`.

When you run `ip a` from the host, you should see the built in NIC and USB NIC appearing as interfaces, with an assigned IP addresses for the built in (LAN) one. THE NIC (WAN) interface gets it's IP address from the ISP (either statically or via DHCP, depending on your homes internet. My WAN IP is assigned via DHCP, but you may need to assign it yourself if your ISP gives you a static one.).

**6. Assign interfaces in OPNsense**

Until now, only Proxmox itself is using the interfaces. We need to assign them in our VM too so that OPNsense can use them. 

In the OPNsense console, select option `1` to Assign Interfaces. 

- Enter `N` for LAGGs
- Enter `N` for VLANs
- The available interfaces will be listed. It will ask to assign 1 to WAN. Do `vnet1`, which is the interface for `vmbr1`, our WAN interface on the USB NIC.
- If prompted, don't assign an IP address to WAN (so that it can be assigned via DHCP. Unless, as stated before, your ISP gives you a specific one, then assign that one).
- Assign `vmbr0` to LAN
- Assign the LAN IP address to `192.168.10.2` (for my example).
- Enter `Y` when prompted to enable DHCP for LAN.
- You can probably `N` on everything.

**7. Configure from the OPNsense Web Console with the Setup Wizard**

In the VM console in Proxmox you will see a few IP address listed above the options: one is the LAN you just set and one is the WAN (either set statically or assigned by DHCP). The web console is accessed at the LAN IP address. In order to reach it, your client device needs to be on the its same subnet. You can set that statically or temporarily.

The Wizard is the easiest way to configure everything. After logging in to the web console you should drop to the installation wizard automatically. If you don't, go to `System->Configuration->Wizard`. It will walk through and apply the base configurations automatically. These are some things it will set up:

- Set a host name. Make it obvious, like `opnsense`
- Don't enable DNS (unless you know what you are doing with it). Leave the rest default.
- Set your correct timezone, important for logs and cert validation.
- Leave NTP servers default.
- Set the WAN to IPV4 DHCP
- You can leave Block private networks and Block bogon networks off.
- Set the LAN IP statically (the same as what you set before i.e. 192.168.10.1/24. Note: this is the LAN address of OPNsense, not of the Proxmox host)
- Set a root password

Once it finishes, reboot.

**8. Update**

After getting the initial configurations set up, it's time to update. Check the left menu bar and go to `System->Firmware->Status`. Click `Check for Updates` and let the update checker run. If there is an update, let it apply, and then reboot the VM from Proxmox so it applies.

If the update hangs, or upon checking for updates again the same update shows up, you can also update from the console in Proxmox. Pick option 12, choose Fetch Updates and Apply Updates. Say `Yes` to rebooting. When the patch notes appear press Space to scroll through them, and the `q` to let the updates finish installing. The VM should reboot itself when it finishes.

**9. Finish Manual Configurations**

1. Check that LAN-side DHCP is enabled
    - Go to `Services → DHCPv4 → LAN`.
    - Make sure it's enabled
    - Set a range (like 192.168.10.100/24 - 192.168.10.200/24)


You'll know everything is working if everything in your LAN can reach each other and the internet (again, make sure every device is using the internal router LAN IP address as their gateway)

<hr>

The following instructions detail how to setup Tailscale on a router, to make the entire LAN accessible via Tailscale subnet routing.

**1. Install Tailscale**

Go to `System → Firmware → Plugins`. Click the `Show community plugins` box on the far right. 