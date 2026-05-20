---
title: Arch
layout: default
---

<img src="/jpprojects/images/images/arch.png" class="float_img" alt="Arch">

## Arch

Arch has a reputation of being difficult to install/use. Compared to other operating systems, the extreme level of control and customization does make Arch a very granular system that requires careful attention to install properly. Arch is designed to be as minimal as possible, relying on the user to choose and install every desired package and functionality.

I was guided (shout out Eason) to use `archinstall` to install a base arch system, and then installed [ml4w](https://ml4w.com), a specific tuning/flavor of arch, on top.

#### 1. Create bootable drive

You download an arch iso from one of the mirrors found [here](https://archlinux.org/download/#http-downloads).

I downloaded that iso to my [Ventoy](/jpprojects/projects/ventoy) usb drive. Elena Etecher can also be used to create the bootable medium.

#### 2. Boot to the drive

On the device arch will be installed to, you have to prepare the BIOS to boot from the usb drive. While restarting the pc (with the usb drive plugged in), spam the F2 or F12 or DEL key to enter the bios. Somewhere in the boot settings, find the boot order and set to boot from the USB drive first. Then save and exit.

You should see the screen blow up with scrolling text as the arch live iso environment launches.

#### 3. Install with Archinstall

When the boot finishes you are in a live environment, running from the usb drive, where changes wont permeate between reboots. So, you need to install arch onto the hardware disk.

Run `archinstall` to run the guided installation. Navigate with the arrow keys, enter and esc. Any blank section is a section that will not have any service or package installed for it. Be especially careful with user accounts and network management.

#### 4. Install ml4w

Shortcuts : 

#### 5. Set up snapshots

Resource : [Snapshots with BTRFS](https://www.youtube.com/watch?v=V1wxgWU0j0E)