---
title: OPNsense
layout: default
---

## OPNsense

Opensense is a robust, open-source router software platform. It began as a fork of pfSense and m0n0wall and is generally considered more user friendly. Setting up a virtual router is not exactly trivial, but if you are careful it can be done.

These are the steps for configuring an OPNsense VM in Proxmox.

<div class="info">
One of the parts that makes this tricky is the fact that routing, naturally, requires two network ports: one for the LAN side, one for the WAN side. If your Proxmox host server does not have 2 ports, you have a few options. Adding a new network card can be expensive depending on the host, so a much cheaper, albeit less ideal option, is to buy an RJ45 to USB adapter to act as the second network interface. I used <a href="amazon.com/dp/B09GRL3VCN ref=ppx_yo2ov_dt_b_fed_asin_title">this one</a> from TP-Link: it's cheap and works reliably with Linux systems (which Proxmox is). This page will be written with this strategy in mind.
</div>

<div class="info">
This is a very networking heavy project. One way to reduce headaches later is to solidify your network topology now. For sake of simplicity, I put all of my machines on a single subnet (i.e. 192.168.10.x/24). This will be your LAN subnet. Machines and services not explicetly assigned an IP address within that range will be assigned one via DHCP, which may affect your ability to connect to them later. It's worth the investment to get your ducks in a row now. Quack.
</div>

**1. Download the OPNsense ISO** 

Download <a href="https://opnsense.org/download/">here</a>. Be sure to Download the AMD64, VGA installer. 

**2. Upload the ISO to Proxmox**

- Access the Proxmox Web UI
- Click on your node (on the left side, under "Datacenter")
- Select the "local" storage option
- Go to "ISO Images"
- Click "Upload" on the top left
- Select the Ubuntu ISO from the last step
- Wait for the upload to complete, then close the upload window

Make sure you see the iso listed 