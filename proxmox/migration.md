---
title: Migration
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">

## Migration

There may come a time when a Proxmox server needs to move hosts, usually because of restrictive hardware. Examples of reasons to migrate include lack of memory, storage or compute, hardware form factor needs, or power usage concerns. VMs and system configurations can be easily moved from one server to another with terminal commands and the web GUI.


<div class="info">
This method of migration assumes you have one Proxmox server with VMs and configurations (original server), and another fresh install of Proxmox on another machine (new server) on the same LAN. Follow the <a href="https://jacob-parra.github.io/jpprojects/proxmox/proxmox">Dedicated Proxmox Server</a> project page if needed 
</div>

#### 1. Create Backups

On the original server, enter the host terminal. This can be done on the machine itself, or via the web GUI by selecting your server node on the left sidebar, then clicking "Shell" in the interior left sidebar.

1. Create backups of all VMs : `vzdump --all --mode stop --compress zstd --storage local`
2. Send the backups to the new server : `scp /var/lib/vz/dump/* root@<new server ip>:/var/lib/vz/dump/`

These commands can take a while to finish, especially if there are many large VMs in the node.

#### 2. Restore Backups

On the new server, select the host storage in the left sidebar (probably called "local"). Then go to  "Backups" in the interior left sidebar. The VM backups should be listed. Select a VM, then click "Restore" in the top menu. Restore each VM one at a time and check that they appear under the new server Node.
