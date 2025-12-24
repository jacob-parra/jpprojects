---
title: Tailscale VPN
layout: default
---

## Tailscale VPN

The Tailscale VPN allows all connected devices to behave as if they were on the same LAN. This enables access to services hosted on the Desktop from any VPN-connected device from anywhere and on any WiFi.

The following steps detail Tailscale configuration:

1. **On the main/hosting desktop, download tailscale** (https://tailscale.com/download)
2. **Login**
> Note that the account used to login here will be the same account used to login to Tailscale on all future connected devices. Your network is tied to this account. I signed with my gmail.
{.is-info}
3. **Enusre that Tailscale is running**
This can be done by checking the active processes: Press Windows+R and type "services.msc" This pulls up the Services menu. Find Tailscale and confirm that its Status is "Running" and its Startup Type is "Automatic. Right click the process and go to Properties to change those values on the General tab if needed.
4. **Enable the desktop to be a "Subnetwork Router"**
Open Powershell as an Admin. Enable Tailscale subnet routing with this command: `tailscale up --advertise-routes=192.168.0.0/24`. Approve this route in the Tailscale Admin Console (https://login.tailscale.com/admin/machines) by clicking "Approve" next to the “Subnet routes available” popup banner.
5. **Install Tailscale on connecting devices**
Follow steps 1 and 2 to Install Tailscale on any other device to join the network. Android and IOS apps are also available.
6. **Test connectivity**
Confirmed that desired devices are properly connected by checking for the green circle next to the device on the Admin Console Machines tab. Test the connection by pinging other connected devices by their Tailscale IPs found next to the device on the Admin Console Machines tab.
