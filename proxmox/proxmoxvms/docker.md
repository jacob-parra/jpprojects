---
title: Proxmox Hub
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">
<img src="/jpprojects/images/images/docker.png" class="float_img" alt="Docker">

## Docker Container

Docker is one of, if not the most popular containerization platform. It's open source and free to use, used to create and manage containers (low resource, lightweight, very fast "VMs"). Thing is, Docker is not, itself, an operating system. So for this machine, a lightweight, CLI only install of Debian is used as the host environmnet for Docker. This adds a dimension of complication and locks the container to CLI only in exchange for being very lightweight and fast.

This page is in 2 parts: first for creating the Debian VM and then installing and using Docker.

<hr>

### Part 1 : Debian Container

#### 1. Download the Debian Template

Expand your server in the left menu, and click on the server storage, probably called `local`. Go to CT Templates, and click Templates at the top.

Search for `debian-12-standard` template, download it, and wait for it to finish. You will see it listed if successful.

#### 2. Create the Container

Click the blue `Create CT` button in the top right and set these configurations:

- General
    - Set the Container ID
    - Set the hostname
    - Set and confirm the root password
    - Uncheck Unprivileged container
- Template
    - Set the Template to the Debian template from the last step
- Disks
    - 32 GB is plenty, but this may depend on what you want to deploy in this container
- Cores
    - 1 is probably fine, but this may depend on what you want to deploy in this container
- Memory
    - 1024 is probably fine, but this may depend on what you want to deploy in this container
- Network
    - Set an IP address
    - Set a Gateway
- DNS
    - Leave as use host settings
- Confirm
    - Check that everything is ok and click finish at the bottom

Give the container a moment to spin up, you will see it in the left menu listed under the server.

#### 3. Additional Configs

In the server (not the container you just made, the server the container is in), access the Shell. Run this command to access the containers config (the CTID is listed by the container name in the left menu): `nano /etc/pve/lxc/<CTID>.conf`. 

Add these lines in the config file: 

```
features: nesting=1,keyctl=1
lxc.apparmor.profile: unconfined
lxc.cgroup.devices.allow: a
lxc.cap.drop:
```

Ctrl + O and Ctrl + X to save and leave.

#### 4. Enable SSH

Configs need to be set in order to SSH or SCP to this container.

Access the config file: `nano /etc/ssh/sshd_config`.

Find and change or add this line: `PermitRootLogin yes`.

### Part 2 : Docker


#### 1. Install Docker

This is where the copy and pasting is going to be very handy.

- Update : 
```
apt update
apt upgrade -y
apt install -y ca-certificates curl gnupg
```
- Add Docker's GPG key:
```
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg
```
- Add the Docker Repo:
```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null
```
- Install Docker
```
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Make sure that everything worked with `docker --version`.

<div class="info">
The container may come without `tee`. Run `apt install coreutils sudo -y` to install it.
</div>



#### 2. Finishing Touches

First, check that auto-start is enabled (which is the default, but good to check).
    - `sudo systemctl enable docker`
    - `sudo systemctl enable containerd`

Second, organize the Docker stuff for a clean layout:
    - Make a Docker directory : `sudo mkdir -p /opt/docker`


<hr>

### How to Docker CLI

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