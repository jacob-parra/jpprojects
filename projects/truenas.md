---
title: TrueNAS
layout: default
---

## TrueNAS
A NAS (Network-Attached Service) is a kind of server that provides storage for machines on the same network (LAN). This allows multiple machines to share the files and storage. TrueNAS is a Debian-based NAS Operating System that can be locally hosted. It is simple to configure with a browser GUI. TrueNAS can be flashed to dedicated hardware or virutalized. For convenience, this method uses virtualization from Windows 11 (also works on 10). Because of the nature of a NAS, this project has certain hardware requirments:

- At least 8GB of available Ram (16+ recommended, but 8 is fine)
- At least 50-100GB of available storage
- Virtualization enabled

The following steps detail NAS configuration:

1. **Install a VM Platform**
VirtualBox is the easiest option, though hypervisors like Proxmox are also great, especially for managing multiple VMs. Download VirtualBox here (https://www.virtualbox.org/wiki/Downloads). Select the Windows hosts option.

2. **Download TrueNAS SCALE ISO**
This is the image of the TrueNAS OS our VM will run.  (https://www.truenas.com/download-truenas-community-edition/) Download the current version and check that it has the .iso extension.

3. **Create the Virtual Machine**
- In VirtualBox, select "New" in the top menu.
- Set "Name" to "TrueNAS".
- Set "Type" to "Linux"
- Set "Version" to "Debian (64-bit)"
- Click "Next"
- In the RAM tab, allocate (at least) 8GB of RAM
- In the CPU tab, allocate 2 cores (the minimum required, but won't be enough to run Docker nor apps)

Before starting the machine, configure the following settings in "Settings":
- In the System tab, Motherboard section, set "Boot Order" to "Optical Disk First". Make sure the Boot Order is "1. Optical" and "2. Hard Disk". Uncheck "Enable EFI" (TrueNAS works best with BIOS boost)
- In the System tab, Processor section, set 2 CPUs and enable "PAE/NX"
- Where it says "Create a virtual hard disk now?" Choose "Yes", 16 GB size, "Type" set to "VDI". This is the OS disk.
- In the Storage tab, create a second disk for the NAS storage itself: Under "SATA Controller" click the icon with a plus and a hard drive icon; Click "Create New Disk"; Set "Disk Size" to at least 100 GB (Closer to 250GB is most ideal); Check that "Type" is "VDI".
- In the Network tab, navigate to and enable "Adapter 1". Set Attached to" to "Bridged Adapter". Then set "Promiscuous Mode" to "Allow All". Check the "Cable Connected option". This allows the NAS to appear on the LAN.

4. **Attach the TrueNAS ISO**
While still in the settings, go to the Storage tab. Click the empty optical drive, then click the vlue CD Icon. Select the TrueNAS ISO downloaded in step 2.

5. **Start the VM and Install TrueNAS**
Start the VM with the Green Go Arrow in the top menu.

The VM console should boot into the TrueNAS installer. Choose the Install/Upgrade option, and select the small OS disk option (not the 100 GB option). Allow the machine to wipe and install, and then set a root password. When it asks about the boot environment choose "BIOS".

Once it finishes navigate to VirtualBox, then Devices,Optical Drives and finally Remove the ISO. Then, reboot the VM.

6. **Access the TrueNAS from your Browser**
The TrueNAS VM Console should display an IP address:

The web interface is at:
http://192.168.x.x

Open a browser and visit http://<that-ip>. Log in with Username: root and the root password set in step 5.

7. **Create a Storage Pool**
In the TrueNAS UI, navigate to the Storage page on the left sidebar and click "Pools". Click "Create Pool" and name it "tank". Select the big (100 GB) disk. Click Add VDev. Set "Layout" to "Single Disk" and click "Create". The storage is now ready

8. **Create shared folder/dataset**
Navigate to Storage, then Pools, then tank. Click "Add Dataset" and name it NASshare. Click "Save"

9. **Create SMB Share**
In the left sidebar, navigate to "Shares". In the SMB section, click "Add". Make sure the path is `/mnt/tank/NASshare`. Set the name to NASshare. Set "Enable SMB service?" to "Yes".

10. **Connect to the NAS**

On Windows, press Win + R. Type \\<TrueNAS-ip> and hit enter. NASshare should display and can be mapped as a drive by right clicking and selecting "Map Network Drive".

