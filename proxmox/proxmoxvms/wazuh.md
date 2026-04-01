---
title: Wazuh
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">
<img src="/jpprojects/images/images/Wazuh.png" class="float_img" alt="Wazuh">

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

```
systemctl restart wazuh-dashboard
systemctl restart wazuh-manager
systemctl restart wazuh-indexer
```

Once you know what the n a device on the same lan, visit the Wazuh Server IP address assigned in Step 2 in the browser. Login with `admin/<admin password>`. 

<hr>

### Second, the Agents

An agent gets installed on every host that you would like to monitor and get logs from. You can install agents on physcial hosts as well as VMs and containers.

#### 1. Get the install command

On the Wazuh Dashboard, click the down arrow at the top and click Agents. On the agents dashboard click "Deploy new agent".

This will take you to the installer wizard, which will create a command you can run on the device you are installing the agent to for fast setup. You need to configure the install command with the right options with the wizard.

Depending on the device you are installing the agent to you, pick the right install version. For most devices, `DEB amd64` is the right option (if it is not you will find out when you try to run the install command.)

You could set an agent name and add to a group if you'd like. If you don't, the agent name defaults to the host device name. Also, add the IP address of your Wazuh Server.

The install command will be generated in section 4, which will probably look something like this: `curl -sO https://packages.wazuh.com/4.x/wazuh-agent.sh / WAZUH_MANAGER='192.168.x.x' bash wazuh-agent.sh`.

<div class="info">
After running the agent install command, you may need to set WAZUH_MANAGER in the configs to manually be the ip address of server.
</div> 

Edit the config with `nano /var/ossec/etc/ossec.conf`. 10 lines down or so, find the line that says `<address>MANAGER_IP<address>` and set the wazuh server IP address there.

#### 2. Run install command

On the host you are adding, run the install command in the terminal.
Then start the agent: 

```
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent
```

Verify it's status with `systemctl status wazuh-agent`.

#### 3. Check the Dashboard

Make sure you see the agent appear in the Wazuh Server, and that it's name and logs are appearing properly. 

<hr>

## Helpful commands

#### Server

- Manage agents (from the wazuh server) : `sudo /var/ossec/bin/manage_agents`.
- View server configs : `cat /var/ossec/etc/ossec.conf`.

#### Agent

- Reenroll an agent : `/var/ossec/bin/agent-auth -m <Wazuh Server IP>`.
- View agent logs : `tail -f /var/ossec/logs/ossec.log`.
- Control agent service : `systemctl <start/status/enable/restart/stop> wazuh-agent`.

<hr>

## Wazuh on OPNsense

OPNsense has a native way to give logs to Wazuh. Go to `System > Settings > Logging` and go to the remote tab. Click the orange + button on the right to add a new destination. 

- Enabled : Check
- Transport : TCP(4)
- Applications : firewall
- Levels : warn, error, critical, alert, emergency
- Facilities : Nothing
- Hostname : opnsense (or something similar)
- Description : Add a good description.