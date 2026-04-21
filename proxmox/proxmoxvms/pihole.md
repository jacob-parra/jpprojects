---
title: Pi-Hole
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">
<img src="/jpprojects/images/images/pihole.png" class="float_img" alt="Pihole">

## Pi-Hole

Pi-hole is a DNS server that excels in DNS filtering. It's free to use and does not require https. It can be run in a container with very few resources. I pointed my OPNsense router, and all DHCP leases, and set all static IP machines, to use Pi-hole as their DNS server to help monitor DNS traffic and help block ads and other unwanted traffic.

This is how I configured my Pi-hole DNS server, as well as the changes I needed to do to get all devices to use it reliably.

<div class="info">
Note: DNS is notorious for causing headaches.
</div>

#### 1. Pull the Container Template.

In Proxmox, select on the node this container is going on. Go to the storage of this node (probably called local) and go to CT Templates in the inner left menu.

Click Templates above, and search for debian-12-standard. Click the Download button in the bottom right to download it to the node.

#### 2. Create the container

While in the same server, click the blue Create CT button in the top right.

- General 
    - Set the CT ID and Hostname
    - Set and confirm the password for the VM
- Template
    - Select the Debian template downloaded from the last step
- Disk
    - Set Disk size to 8 GB
- Cores
    - Leave Cores at 1
- Memory
    - Set Memory to 1024
- Network
    - Set a static IP address, with the CIDR Subnet Mask
- DNS
    - Set DNS servers to 8.8.8.8

Confirm and click Finish at the bottom to create the container.

#### 3. Install Pi-hole

Start the container and get into the shell. Login to user `root` with the password created in the last step.

Update and upgrade with `apt update && apt upgrade -y`.

Then install Pi-hole with `apt install curl -y`.

Finally, run the Pi-hole installer with `curl -sSL https://install.pi-hole.net | bash`.

The installer walks through some configurations. Most defaults can be left, but you do need to choose an upstream DNS server (like Google or Cloudflare). If asked, enable both the web admin console and query logging.

When the installer finishes, note the admin password on the last screen. That is needed to login to the web console, accessible at the IP address of the container. If needed, this password can be reset from the container: `pihole -a -p`.

#### 4. Set Pi-hole as the OPNsense default DNS Server

In OPNsnese, go to `System > Settings > General`. Under the Networking section, set the first listed server to be the IP of the Pi-hole container with none as the Gateway. 

Set a backup (like 8.8.8.8 or 1.1.1.1) after the Pi-hole server, with WAN_DHCP as the gateway (if 2 are listed, one is for IPv4 and the other for IPv6. Choose whichever has an IP address).


Click Save at the bottom to apply the changes.

#### 5. Create NAT rules

<div class="info">
This step SHOULD point all DNS traffic to Pi-hole, and it worked for some VM's and Containers that didn't have explicit DNS servers, but I ended up needing to fix DHCP assignment anyways in step 6.
</div>

We need 2 NAT rules: First, a rule to let Pi-hole send DNS traffic out to the internet, and Second, a rule that redirects all other DNS traffic not going to Pi-hole to Pi-hole.

To create these rules, go to `Firewall > NAT > Destination NAT`. Click the + button to add a rule.

First Rule (let Pi-hole out): 

- Set a description
- Set Interface to LAN
- Set Protocol to TCP/UDP
- Set Destination Address, Destination Port, and Redirect Target Port to any.
- Toggle Advanced Mode in the top left, and enable no RDR under Options (indicating that no redirect is necessary)
- Save

Second Rule (redirect all DNS traffic to Pi-hole):

- Set a description
- Set Interface to LAN
- Set Protocol to TCP/UDP
- Enable Invert Destination (so all traffic NOT to Pi-hole gets caught)
- Set Destination Address to Single host or Network and put the IP of the Pi-hole container
- Set Destination Port to DOMAIN (53)
- Set Redirect Target IP to Single host or Network and put the IP of the Pi-hole container
- Set Redirect Target Port to DOMAIN (53)

The order of these rules is important, as the first that can apply is applied. If backwards, Pi-hole will not be able to reach the internet and traffic will struggle to leave your lan.

Click apply.

#### 6. Fix DHCP Leases

Your DHCP servers are listed under Services in the left menu. My router uses `Dnsmasq DNS & DHCP`. From there, go to DHCP options.

Use the plus button on the right to add an option (basically a setting that all devices that recieve an IP from this server will get). 

- Set interface to LAN
- Set Type to Set
- Set Option to dns-server [6]
- Set Value to 192.168.10.2
- Enable Force
- Set a description ("Give Pi-hole as the DNS server for all DHCP devices")

Save, and then apply. All new leases will have Pi-hole set as the DNS server, but existing leases need to be refreshed.

In the OPNsense shell (available with option 8 in the OPNsense terminal, which you may need to SSH to), run these commands:

- Remove existing leases `rm /var/db/dnsmasq.leases`
- Restart the DHCP service `service dnsmasq restart`

#### 7. Configure other machines

Other machines that had their IP address statically given may also have a static DNS server. Check each to make sure it is using Pi-hole as the DNS server.

Some devices may have cached an old DNS server, and may need to be flushed in order to use Pi-hole.

#### 8. Create Pi-hole redirect rule

You can use Pi-hole for DNS to redirect queries to `https://servicename.lan` to specific services. This is espeically useful for services that require HTTPS through Caddy or nginx.

In Pi-hole, go to `Settings > Local DNS Records` in the left menu. Under Local DNS records, fill in the Domain and Associated IP, and click the green + button to add a record. (For example, set Domain to notes.lan and Associated IP to the nginx server IP address).

