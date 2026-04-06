---
title: Ventoy
layout: default
---

<img src="/jpprojects/images/images/ventoy.png" class="float_img" alt="OPNsense">

## Ventoy

Ventoy is a clever bootable drive system. Rather than flashing one .iso or .img file to a usb drive to create a bootable drive at a time, Ventoy can have multiple image files at a time. When plugged in as a bootable drive, Venoty will show all the images it contains in the boot menu as individual "bootable drives". This can be very convenient to collect lots of images without needing to reflash a bootable drive over and over.

This are the instructions for creating a Ventoy drive.

#### 1. Download Ventoy.

The Windows download is available [here](https://sourceforge.net/projects/ventoy/files/v1.1.11/). 

<div class="info">
The download for Ventoy is only availble on Windows or Linux. I did this on Windows, and the process looks a little different on Linux.
</div>

#### 2. Install to a USB drive.

First, make sure the usb drive you are going to use is plugged in. Note that this drive will be wiped during this process.

Find the download in file manager and extract it. Open the resulting folder, right click Ventoy2Disk.exe and "Run as Administrator".

In the pop up menu, select your usb drive and click Install. Confirm twice. 

#### 3. Add image files.

<div class="info">
Note : Adding images to the Ventoy drive once it has been creating can be done on Windows, Linux or Mac.
</div>

After the installation finishes, unplug and replug the usb. It will appear in the file manager as a normal storage location.

Images can simply be drag-and-dropped into that location. No formatting is needed, though folders can be used for organization if desired. 

<div class="info">
.iso files work best with Ventoy. Most .img files work as well, but are generally more hit or miss. When possible, use .iso files.
</div>

Now when using this usb drive as a bootable drive, every image file will appear in the boot menu, as if they were all plugged in as bootable drives at once.