---
title: ZimaOS
layout: default
---
## ZimaOS NAS box

Zima is a simple, open-source NAS operating system. It is less powerful and controlable than TrueNAS, but also much more simple and polished. I chose Zima because it still gives lots of control and power to you as the admin while still feeling very clean, which makes it much more appealing and easy to use for those less-technical in my family. For example, along with a very clean browser file explorer, it also has IOS and Android apps that give access to all apps and features in one place. It's support for Docker Apps and RAID configurations was also a factor for deciding to go with Zima.

These are the steps for configuring a simple Zima server

<div class="info">
ZimaOS, though suitable for a general server, thrives as a NAS server first and foremost. Because of that, you'll have the most stable and redundant experience by installing on hardware that supports multiple hard drives for RAID configuring. You can buy a rack server, buy a consumer NAS, or build your own server. Buying a consumer NAS ended up being the most cost effective option for me, and I went with a Terramaster F4-425. I would recommend going for a machine with at least 4 drive bays so you can use 1 for the boot/system drive and the others in a RAID 5 or 6 configuration.
</div>

#### 1. Download ZimaOS

ZimaOS can be downloaded [here](https://www.zimaspace.com/zimaos/download). 

<div class="info">
ZimaOS is free to use, and you can create up to 3 member accounts with up to 4 storage drives per server. However, to create more than that you must buy a lifetime license for $30, which is not a bad deal; Also, supporting OS/Program projects is cool.
</div>

#### 2. Flash to a Bootable Drive

Use something like <a href="https://etcher.balena.io/#download-etcher">Balena Etcher</a> to flash the Zima ISO to a flash drive to make it a bootable drive. Then plug it in to the host while the host is off. Also plug in the monitor and a keyboard. Then boot the host.

#### 3. Boot from Drive

While booting the host machine, spam the F12 key (or whatever the Boot Order key is, maybe F10 or F2 or something) to enter the Boot Order. There, select your USB drive.

#### 4. Install

The Zima Installer will appear and ask where disk to install to. The selected disk will be wiped. Be careful to NOT select your usb stick, or any other option that doesn't look right.

<div class="info">
The ideal way to run Zima is to use an SSD for system and app data storage and HDDs for bulk file/image storage. This way Zima and any apps run super fast while storage is cheap per GB. Be careful where you are installing Zima to, and keep bulk data on other drives.
</div>

After the installation finishes, let the system reboot

#### 5. Access the GUI

After rebooting the terminal will display the IP address. Go to this IP address in the browser to finish setting up. This will include creating the admin user (which does NOT count towards your 3 free user accounts actually). You may also need to set the region.

#### 6. Configure Storage

After the initial setup, click the gear/settings icon of the Storage section on the left. Besides your system storage, you'll see a banner option to configure storage (make sure your hard drives are plugged in by now). Click on the arrow of the banner and follow through the steps to configure your drives.

You will have the option to pick a RAID configuration, as well as select which drives you want included in it. This becomes a storage pool, basically a single "drive" for storage, comprised of multiuple drives behind the scenes. The name you give to this pool cannot be changed, so choose wisely.

#### 7. Other Settings

While in the Settings (also accessible with the settings/gear icon in the top left of the dashboard) go to the Network tab. There you can click on the 3 dots in the Ethernet section to manually set an IP address

Then go to the General tab. I recommend set the Disk Standby to something short, like even 10 minutes. This lets the hard drives spin down while not being used. This will reduce both noise and power consumption, as well as increase the lifespan of your disks.

#### 8. Developer Mode

While still in the General tab, scroll to the very bottom to Developer Mode and click View. Here you can toggle "SSH Access" to yes, and click the arrow of "Web Based Terminal" to access a the shell for the server in the browser. This is very handy!