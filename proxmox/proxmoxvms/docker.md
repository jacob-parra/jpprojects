---
title: Proxmox Hub
layout: default
---

## Docker VM

Docker is one of, if not the most popular containerization platform. It's open source and free to use, used to create and manage containers (low resource, lightweight, very fast "VMs"). Thing is, Docker is not, itself, an operating system. So for this machine, a lightweight, CLI only install of Debian is used as the host environmnet for Docker. This adds a dimension of complication and locks the machine to CLI only in exchange for being very lightweight and fast.

This page is in 2 parts: first for creating the Debian VM and then installing and using Docker.

<hr>

## Part 1 : Debian CLI VM

**1. Download the Debian ISO**

We will be using Debian 12 <a href="https://cdimage.debian.org/cdimage/archive/12.0.0/amd64/iso-cd/">(debian-12.0.0-amd64-netinst.iso)</a>

**2. Upload the ISO**

- Access the Proxmox Web UI
- Click on your node (on the left side, under "Datacenter")
- Select the "local" storage option
- Go to "ISO Images"
- Click "Upload" on the top left
- Select the Ubuntu ISO from the last step
- Wait for the upload to complete, then close the upload window. It will be very fast as the ISO is only about half a Gigabite.

Make sure you see the iso listed.

**3. Create the VM**

This has a lot of steps, but there is *some* room for error. These configurations are organized by section/tab:

- General
    - Leave the default VM ID
    - Set a name (something like docker-01, or debian-01.)
    - Click "Next"
- OS
    - ISO Image: select the Debian ISO
    - Keep "Guest OS" as "Linux"
    - Version: 6.x - 2.6 Kernal
    - Click "Next"
- System
    - BIOS : OVMF (UEFI)
    - Machine : q35
    - SCSI Controller: VirtIO SCSI
    - QEMU Guest Agent: Checked
    - Click "Next"
- Disks
    - Bus/Device : VirtIO Block
    - Storage : local-lvm (or whatever is available)
    - Disk size : 32 GB minimum, suggested 45 GB +
    - Discard : Check the box
    - Click "Next"
- CPU
    - Cores : 2
    - Type : host (scroll down, it's probably on the bottom)
- Memory
    - Set 4096 (it's listed in MiB)
    - Click "Next"
- Network
    - Bridge: vmbr0
    - Model: VirtIO (paravirtualized)
    - Click "Next"
- Confirm
    - Make sure everything is right
    - Check the "Start after created" box
    - Click Finish

**4. Finish the Installation**

Follow these steps for post-creation installation options. Most are pretty predictable, but some are not. Safest to just follow along.

- Enter on first "Graphical Install" option
- Set language
- Set region
- Set Keyboard
- Set host name (like `debianvm`) debiandockervm
- Leave domain blank, unless you know what you are doing
- Set user name
- Set username
- Set user password
- Set time zone
- Press enter on default "Guided - use entire disk"
- Keep the default disk and continue
- Keep the default "All files in one partition"
- Review the partition configurations and continue
- Click "Yes" for "Write the changes to disks"
- Wait for the installation to finish
- Keep the default no and continue
- Set your mirror region
- Keep the default deb.debian.org archive mirror and continue
- Keep no for "Participate in the package usage survey" and continue
- Uncheck both Debian desktop envirnoment AND GNOME, and check SSH server, and keep standard system utilities checked
- Wait for the system to finish installing, it can take a while
- Hit continue to reboot, and then sign in

All done! Finally. 

**5. Install the QEMU Guest Agent**

See the [Proxmox Scripting project page](/jpprojects/proxmox/scripting), step 2, for instructions on how to do this.

**6. Install OpenSSH**

See [OpenSSH project page](/jpprojects/proxmox/openssh) for instructions on how to do this.


<hr>

## Part 2 : Docker CLI

**1. SSH in**

SSH in, as these steps require lots of copy and pasting, easiest done from SSH rather than directly in the Proxmox Web GUI. Log in as root, or a user with root priviledge, or as a normal user and then `su` to a user with `sudo`.

<div class="info">
Remeber, this is done with `ssh <username>@<ip>`. Find the Debian VM's IP address with `ip a`, it will likely be the last one listed.
</div>

**2. Install Docker**

This is where the copy and pasting is going to be very handy.

- Update : 
    - `sudo apt update`
    - `sudo apt install ca-certificates curl gnupg -y`
- Add Docker's GPG key:
    - `sudo install -m 0755 -d /etc/apt/keyrings curl -fsSL https://download.docker.com/linux/debian/gpg | \`
    - `sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg`
    - `sudo chmod a+r /etc/apt/keyrings/docker.gpg`
- Add the Docker Repo:
    - `echo \ "deb [arch=$(dpkg --print-architecture) \ signed-by=/etc/apt keyrings/docker.gpg] \ https://download.docker.com/linux/debian \ $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \`
    - `sudo tee /etc/apt/sources.list.d/docker.list > /dev/null`

<div class="info">
The VM may come without `tee`. Run `apt install coreutils sudo -y` to install it.
</div>

- Install Docker:
    - Update again : `sudo apt update`
    - `sudo apt install docker-ce docker-ce-cli containerd.io \docker-buildx-plugin docker-compose-plugin -y`

**3. Allow user to run Docker**

This allows the current user to run Docker without `sudo`. Run `newgrp docker`, then `sudo usermod -aG docker $USER`.

Test that everything is working by running `docker run hello-world`. Output should be see a message that says `Hello from Docker!`.

**4. Finishing touches**

First, check that auto-start is enabled (which is the default, but good to check).
    - `sudo systemctl enable docker`
    - `sudo systemctl enable containerd`

Second, organize the Docker stuff for a clean layout:
    - Make a Docker directory : `sudo mkdir -p /opt/docker`
    - Switch owner of the directory : `sudo chown -R $USER:$USER /opt/docker`

<hr>

## How to Docker CLI

It isn't totally intuitive, but it isn't too tricky either.

- List running containers :                     `docker ps`
- List all containers (including stopped) :     `docker ps -a`
- List downloaded images :                      `docker images`
- Pull a downloaded image :                     `docker pull <image>`
- Remove a container :                          `docker rm <container>`
- Read a containers logs :                      `docker logs <container>`

- Run a container :                             `docker run <container>`
- Start container :                             `docker start <container>`
- Restart container :                           `docker restart <container>`
- Stop container :                              `docker stop <container>`

- Start a docker-compose.yml :                  `docker compose up -d`
- Stop a docker-compose.yml :                   `docker compose down`