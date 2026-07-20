---
title: Proxmox
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">

## Stop using the Enterprise Repos

I regurlary got automatic update errors for my servers, and getting off of the enterprise repos will stop these errors.

#### 1. Run these commands

These commands are just replacing enterpise repos with public repos or otherwise disable them.

```
sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/ceph.list 2>/dev/null
echo "deb http://download.proxmox.com/debian/pve trixie pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
echo "deb http://download.proxmox.com/debian/ceph-squid trixie no-subscription" > /etc/apt/sources.list.d/ceph.list
mv /etc/apt/sources.list.d/pve-enterprise.sources /etc/apt/sources.list.d/pve-enterprise.sources.disabled
mv /etc/apt/sources.list.d/ceph.sources /etc/apt/sources.list.d/ceph.sources.disabled
echo "deb http://download.proxmox.com/debian/ceph-squid trixie no-subscription" > /etc/apt/sources.list.d/ceph-no-subscription.list
```