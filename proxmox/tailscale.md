---
title: Proxmox Tailscale
layout: default
---

## Tailscale on Proxmox

Your entire proxmox server, and the VMs it manages, can be made accessible over Tailscale. Tailscale is installed on the Proxmox host machine, the server itself, NOT on individual VMs.

<div class="info">
See the <a href="https://jacob-parra.github.io/jpprojects/projects/tailscale">Tailscale project page</a> to see how to create a Tailscale VPN.
</div>

**1. Accessing the Terminal**

SSH into the proxmox machine, or run the following commands locally. Follow step 7 to do so.

**2. Install and Configure Tailscale**

- First, run `apt update` (sudo not needed as we only have the root user). 
- Install Tailscale with `curl -fsSL https://tailscale.com/install.sh | sh`. Ensure that it installs correctly. If it doesnt, make sure you did step 8 correctly. 
- Run `sudo tailscale up --advertise-routes=192.168.0.0/24` to turn on Tailscale . Tailscale will return a link to sign in to with your Tailscale account on another browser. After signing in, go to the Tailscale Admin Console to approve the route and rename the machine if desired.

<div class="info">
The exact route in this last command may differ. Double check your Tailscale configurations.
</div>

The Proxmox server will now be accesible from anywhere via its Tailscale IP address and port 8006.