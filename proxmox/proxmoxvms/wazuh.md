---
title: Wazuh
layout: default
---

## Wazuh

Wazuh (pronounced Waw-zuhh) is a free and open source SIEM (Security Information and Event Management) tool. It is used for compiling logs from many machines and unifying them into practical dashboards. It is comprised of many parts, but the most important are the **Wazuh Server** and the **Wazuh Agent**: The server is the machine that collects and catologues the logs and the agent is a service on the machines that are being monitored that sends the logs to the server. 

This page will describe generally how to set up both

<hr>

### First: the Server


I set up the Wazuh Server as a container in Proxmox. If you have the resources a VM may be better as the server has a lot to do but I got it running in a container fine.

#### 1. Download the Ubuntu Container Template

In your proxmox node, go to the "local" storage, click "CT Templates" in the left menu and click "Templates" at the top.

Select `ubuntu-22.04-standard` and download it.

#### 2. Create the Container**

Click the big "Create Container" button at the top right of the page. 

These are the configurations needed for this this container:

- General
    - Set a password
    - Set "Unpriviledged" to "Yes"
- Template
    - Select `ubuntu-22.04-standard` 
- Disk
    - At least 32 GB, 40 would be better if you can
- CPU
    - Set 2 cores
- Memory
    - 4096 MB minnimum, 6144 MB would be better if you can
    - Also disable swap memory
- Network
    - Set the bridge (probably vmbr0)
    - Set a static IP address

Finish and create the VM.

#### 3. Enable required features

In the Proxmox Host shell, edit the container congig file with `nano /etc/pve/lxc/<Container ID #>.conf`.

Make sure `features: nesting=1,keyctl=1` is in there. Save and close when done.

#### 4. Increase memory limits

OpenSearch, a critical feature for Wazuh Server, needs memory locking.

To enable it, first make sure the container is on (you can right click it in the left side bar to start it). While in the shell, edit the container config file with `nano /etc/sysctl.conf`.

Add `vm.max_map_count=262144` in there. Then save and close, and apply the change with `sysctl -p`.

#### 5. Install Wazuh

Download with `curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh` (if curl is not installed yet, install it by first updating `apt update` and installing with `apt install curl`). 

Run the install script that the last command pulled : `bash wazuh-install.sh -a`.

#### 6. Access the Dashboard

The default admin account generates a password for accessing the Web Dashboard. This is not the same as the root user in the CLI. Find out what what the admin password is by first unzipping the installer `tar -xvf wazuh-install-files.tar` and then checking in the passwords file `cat wazuh-install-files/wazuh-passwords.txt`.

The admin password can also be changed with `/var/ossec/indexer/bin/opensearch-users passwd admin`. This will prompt for a new password and confirmation. If you do this be sure to restart affected services: 

- `systemctl restart wazuh-dashboard`
- `systemctl restart wazuh-manager`
- `systemctl restart wazuh-indexer`

Once you know what the n a device on the same lan, visit the Wazuh Server IP address assigned in Step 2 in the browser. Login with `admin/<admin password>`. 

<hr>

### Second, the Agents