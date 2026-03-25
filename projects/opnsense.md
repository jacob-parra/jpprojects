---
title: OPNsense
layout: default
---

## OPNsense

Project coming soon!

Download and unzip to a .img

use balena etcher to flash to a bootable drive

plug in drive, enter bios, set boot order to be the usb first.
Or, wipe the other drive, so it is forced to boot from the usb

Let boot from the usb, don't touch anything until it finishes or you'll reach options you probably don't want.

login with installer:opnsense

go to option 3 (something like other install options)

Select guided UFS option, select the bottom partition option and hit enter to finish. If that doesnt work, try a different partition option or try zfs. if that still doesnt work, look up how to destroy partitions manually.

Let install and reboot



1. Login with root:opnsense

2. 
- 1. Assign Interfaces
- Laggs: n
- vlans: n
- when you see the interface names, if you dont know what they are, unplug everything, do a
- plug in wan cable and hit enter
- do a
- plug in lan cable and hit enter
- press space to skip extra interfaces
- press y to finish

3. 
- 2. Set interface Ip address
- select the number for you wan
- do yes to configure ipv4 address for wan via dhcp
- n for ipv6 via dhcp
- change web gui protocol from https to http : n
- new self signed cert for the gui : n
- restore gui defaults : n

- 2. Set interface ip address
- select the number for your lan interface
- do no for configure ipv4 address for lan via dhcp
- enter address (without subnet)
- enter subnet cidr number
- press enter for none
- configure ipv6 : n
- enable dhcp server on lan : y
- enter start dhcp range
- enter end dhcp range
- change web gui protocol from https to http : n
- new self signed cert for the gui : n
- restore gui defaults : n

4.
- Access the web console at the LAN ip address
- go to System Firmware Status
- click check for updates
- click ok if updates pop up, scroll to bottom and click blue update button
- let update and reboot



## Tailscale on OPNsense

The following instructions detail how to setup Tailscale on a router, to make the entire LAN accessible via Tailscale subnet routing.

#### 1. Install Tailscale

Go to `System → Firmware → Plugins`. Click the `Show community plugins` box on the far right. Search for `os-tailscale`. After installing finishes, reboot.

#### 2. Authenticate Tailscale

In another tab, sign in to <a href="https://login.tailscale.com/admin/settings/keys">Tailscale</a> to generate a key. Once in the Tailscale admin console, go to `Settings` on the top, then `Keys` on the left. Click on the `Generate auth key...` button on the right.

- Keep `Reusable off`
- Keep `Ephemeral off`
- Keep `Expiration Disabled`

Copy the key. You may not be able to access it again.

Then, in the OPNsense web console, go to `VPN → Tailscale → Authentication`. Click the "advanced" toggle in the top left. Set the Login Server to `https://controlplane.tailscale.com`. Paste your key into the `Pre-authentication Key` section and click Apply.

Then go to back to the Machines tab of the Tailscale admin console. Your router should be newly listed at the bottom of the list. Click on the machine name, and then click "Approve" if necessary.

#### 3. Enable the Interface

Back in the OPNsense web console, go to `Interfaces → Tailscale`.

- Click the `Enable` check box
- Set a description if you'd like
- Click the Save button at the bottom

#### 4. Create a Tailscale Firewall Rule

Go to `Firewall → Rules → Tailscale`. Use the little orange + button on the right to add a rule. 

- Action: Pass
- Interface: Tailscale
- Protocol: Any
- Source: Any
- Destination: LAN net

Click the Save at the bottom, then Apply at the top right when back at the `Firewall: Rules: Tailscale` page.


Your router is now part of your Tailscale VPN. The OPNsense web console can be reached by any device connected to the VPN, allowing you to monitor the status of your home network from anywhere.

#### 5. Enable Subnet Routing

Now that Tailscale is on OPNsense, it can be configured to allow external access to every machine in the LAN, without needing to install Tailscale on every machine or VM therein. This is called "Subnet Routing".

Go to `VPN → Tailscale → Settings`. Make sure Enabled and Accept DNS are checked. Also check Accept Subnet Routes if other nodes in your Tailscale network are advertising subnets.

Then go to the `Advertised Routes` tab at the top. Use the orange + button to add a subnet. Put your LAN subnet in the Subnet section (like 192.168.10.0/24) and add a description if you'd like. Click Save, then Apply.

Finally, in the Tailscale admin console, go to the Machines tab. Click on your OPNsense machine and in the Subnet Routes portion click approve on the newly listed subnet route.