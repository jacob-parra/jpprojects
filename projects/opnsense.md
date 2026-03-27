---
title: OPNsense
layout: default
---

<img src="/jpprojects/images/images/opnsense.png" class="float_img" alt="OPNsense">

## OPNsense

Opensense is a robust, open-source router software platform. It began as a fork of pfSense and m0n0wall and is generally considered more user friendly. I would recommend installing OPNsense directly onto bare metal to avoid passthrough headaches.


<div class="info">
I was given a Qotom mini PC which I used for this project. Qotom mini PCs are very low power and quite, while still plenty powerful for a robust router and firewall. There were certain headaches with mine, but I believe newer models are just fine. Any mini pc with enough ethernet ports/interfaces will probably work. There are many options online, but I would recommend getting one used because they can be pretty pricey. Go for something cheap, because you really do not need much compute for a dedicated router/firewall (2-4 cores, 4-8 GB ram, 32-64 GB Disk, 1-2.5 GB ethernet)
</div>

These are the steps for configuring an OPNsense VM.

#### 1. Download the OPNsense ISO

Download <a href="https://opnsense.org/download/">here</a>. Be sure to download the AMD64, VGA installer. 

It will probably download as a very specific `.img.bz2` format (compressed). I used **7-Zip** on Windows to export it properly. You can download 7-Zip <a href="https://www.7-zip.org/download.html">here</a>. Just grab the .exe version. When extracted properly, the file will have a .img extension.

On Mac, just double click the download and it will create the .img.

#### 2. Flash to a USB drive

The installer needs to be flashed to a USB drive, which will later be used to put OPNsense on the machine. I used <a href="https://etcher.balena.io/#download-etcher">Balena Etcher</a> on my Mac and I believe it works on Windows too. 

Using Balena is very straightforward. Upon opening the app click "Flash from file" and select the OPNsense .img installer. Insert your USB Drive, click "Select Target" and select your USB drive. Then click "Flash". Mac or Windows may ask for your password, neccessary to write to a drive.

#### 3. Boot from the Bootable Drive

Plug your hardrive in, as well as the display cable and a keybaord. While booting the system, spam the del key (or F12, or F11, or F2, or F10) to enter the BIOS. Find the section that talks about the boot order, and set the USB to boot first. Then save and exit.

<div class="info">
My mini pc booted so quickly that I could not enter the bios before booting straight to the previously installed os. I circumvented this by wiping the original drive so that the system had to boot from the usb instead. This is valid, but may require some wiggling to fully wipe any partitions and metadata from the original drive. [Crystal Disk Info](https://crystalmark.info/en/software/crystaldiskinfo/) may be helpful for this process.
</div>

Let the system boot from the usb. Don't touch anything until it finishes or you'll start editing options you probably don't want.

#### 4. Install

When the boot finishes, you'll have an option to login. Login to user `installer` with password `opnsense`.

Enter option 3 (should say something like "other install options").

Select guided UFS option. When given the parition version option, select the bottom partition option and hit enter to finish. If that doesnt work, try a different partition option or try zfs. if that still doesnt work, look up how to destroy partitions manually.

Let install and reboot

#### 5. Assign Interfaces

Login to user `root` with password `opnsense`.

Enter `1` for the Assign Interfaces option.
- For LAGGs: n
- For VLANs : n
- When it shows the interface names and asks for the WAN interface, if you dont know what your interface names are, unplug all ethernet cables and enter "a".
- Then plug in WAN cable, make sure the connection is up (lights on) and hit enter.
- When it asks for the LAN interface, enter "a".
- Then plug in LAN cable, make sure the connection is up (lights on) and hit enter.
- Press enter to skip extra interfaces.
- Enter "y" to finish.

#### 6. Set Interface IP addresses

First assign the WAN IP address over DHCP.
Enter `2` for the "Set Interface IP Address" option.
- Select the interface number for the WAN
- Enter "Y" to configure IPv4 address for WAN via DHCP
- Enter "n" for IPv6 via DHCP
- Enter to skip assigning a IPv6 address
- Change web GUI protocol from https to http : n
- New self signed cert for the GUI : n
- Restore GUI defaults : n

Second, assign the LAN IP address statically, and 
Again, enter `2` for the "Set Interface IP Address" option.
- Select the interface number for the LAN.
- Enter "n" to configure IPv4 address for LAN via DHCP.
- Enter LAN IP address (without the subnet).
- Under the subnet mask CIDR notation number (i.e. 24, 16, 8).
- Press enter for none
- Enable DHCP server on LAN : y
- Enter DHCP range start address (i.e. 192.168.1.150)
- Enter DHCP range end address (i.e. 192.168.1.200)
- Change web GUI protocol from https to http : n
- New self signed cert for the GUI : n
- Restore GUI defaults : n



#### 7. Access the Web Console and Update

OPNsense has a great web console to make configuring a little easier. Access the web console at the LAN IP address you assigned in the last step (it should be displayed in the terminal manu near the top). Login to user `root` with password `opnsense`.

In the left menu, go to `System > Firmware > Status`. Click the "Check for Updates" button at the bottom. After the updates are found, click ok if there is a pop up and scroll to the bottom to click blue update button

Let update and reboot, it may take a few minutes. Refresh the web console after a few minutes if it doesnt refresh automatically.

If the update hangs, or if upon checking for updates again the same update shows up, you can also update from the physical terminal. Pick option 12, choose Fetch Updates and Apply Updates. Say `Yes` to rebooting. When the patch notes appear press Space to scroll through them, and then `q` to let the updates finish installing. The system should reboot itself when it finishes.

<hr>

### Tailscale on OPNsense

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

#### 6. Intrusion Detection and Prevention

OPNsense has built in Intrusion Detection that can block malicious traffic.

In the left hand menu of the web console, go to `Services → Intrusion Detection → Administration`. 

- Click the "Enabled" box.
- Set "Pattern Matcher" to "Hyperscan" for Intel systems, or "Aho-Corasick, 'Ken Steele'" for AMD systems.
- Set "Interfaces" to the interface to listen to (probably WAN).

Click the orange Apply button at the bottom.

Then go to the Download tab at the top.

The listed items are essentially databases of known malicious sites and traffic which are regularly updated. I selected:

- abuse.ch/Feodo Trackernot
- abuse.ch/SSL Fingerprint Blacklistnot
- abuse.ch/SSL IP Blacklistnot
- abuse.ch/ThreatFoxnot
- abuse.ch/URLhaus

For each selected ruleset, click the pencil in the right to edit and check the "Enabled" box.

Then click the orange Download & Update Rules. It may take a second to finish, but you'll know its working when the "Last Updated" will not say "not installed".

Right now your rules are operating as Intrusion Detection, noting the traffic but doing nothing about it. These next steps turn the rules into Intrusion Prevention, dropping the traffic entirely.

Then, in the left menu, go to `Services → Intrusion Detection → Policy`. Click the orange plus button on the right to add a rule.

- Make sure the Enabled box is checked
- Set Rulesets to be all of your downloaded rules
- Add a description if you'd like
- Set Action to Drop

Then click Save, and Apply. Give it a sec to apply.

[Additional Help](https://www.thomas-krenn.com/en/wiki/Configuration_of_OPNsense_Intrusion_Detection_and_Intrusion_Prevention)