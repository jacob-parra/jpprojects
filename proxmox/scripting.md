---
title: Proxmox Scripting
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">

## Proxmox Downtime Scripting

Personal servers (probably) do not need to be on all the time. By scripting downtime at night the server uses less electricity and other resources. This page details configurations for automated down-scrits and up-scripts.

#### Down Scripting

A script executed regularly via cron allows for logs to track the down-timing. Some configurations in the Proxmox UI, as well as in individual VMs.

#### 1. Enable QEMU Guest Agent

QEMU gues agent is a lightweight service inside a VM that (among other things) allows the hypervisor (in our case, Proxmox) to communicate directly with the guest OS. It's a safe way to interact with a VM, particularly for powering on and off.

By defauly, Proxmox disables Qemu guest agent for each VM and must be enabled per VM. 

- Select the VM on the left bar, then click Options and then "QEMU Guest Agent".
- Click "Edit" in the top bar, and check the "Use QEMU Guest Agent" box. Proxmox will automatically remind you to install the QEMU Guest Agent in the VM itself. That's the next step.

#### 2. Install the QEMU Guest Agent

These steps need to be run on every VM.

Enter the terminal of the VM itself. Follow these commands to install.

- Install Quemu Guest Agent with `sudo apt update` and `sudo apt install qemu-guest-agent`
- Start with `sudo systemctl start qemu-guest-agent`
- Then check it's working with `sudo systemctl is-active qemu-guest-agent`. It should return `active`.
- Optionally, check the status verbosely with `sudo systemctl status qemu-guest-agent`. You should see `running`.


#### 3. Create the script

In the terminal of the Proxmox host, create the script with `nano safe-shutdown.sh`:

```
#!/bin/bash

LOGFILE="/var/log/proxmox-safe-shutdown.log"
DATE="$(date '+%Y-%m-%d %H:%M:%S')"

echo "========================================" >> "$LOGFILE"
echo "$DATE : Starting safe Proxmox shutdown" >> "$LOGFILE"

# Get list of running VMs
RUNNING_VMS=$(qm list | awk 'NR>1 && $3=="running" {print $1}')

if [ -z "$RUNNING_VMS" ]; then
    echo "$DATE : No running VMs found" >> "$LOGFILE"
else
    for VMID in $RUNNING_VMS; do
        VMNAME=$(qm config "$VMID" | grep '^name:' | awk '{print $2}')
        echo "$DATE : Sending shutdown to VM $VMID ($VMNAME)" >> "$LOGFILE"
        qm shutdown "$VMID"
    done
fi

# Wait for VMs to stop
echo "$DATE : Waiting for VMs to shut down..." >> "$LOGFILE"

while true; do
    STILL_RUNNING=$(qm list | awk 'NR>1 && $3=="running" {print $1}')
    if [ -z "$STILL_RUNNING" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') : All VMs are stopped" >> "$LOGFILE"
        break
    fi
    sleep 10
done

echo "$(date '+%Y-%m-%d %H:%M:%S') : Powering off host" >> "$LOGFILE"
/sbin/poweroff

```

<div class="info">
If you ssh into the Proxmox host you can copy and paste this whole script in. I have not had luck doing that in the Proxmox UI terminal.
</div>

This script sends a safe ACPI shutdown signal to each active VM, then turns off the Proxmox host itself, and logs the whole process. The log is accessible at `/var/log/proxmox-safe-shutdown.log`.

#### 4. Set up the cronjob

- Access the root user crontab with `crontab -e`
- You may be asked to select a text editor to create the crontab file with. Enter 1 for Nano or 2 for Vim.
- Add the following cronjob at the bottom of the file: `0 23 * * * /root/safe-shutdown.sh` (The first number is the minute, the second is the hour, in military time, obviously. Each following '*' represents every day of the month, every month, every day of the week, respectively. Change the hour as needed.)
- Test that the cronjob is set with `crontab -l`. The job should be listed.

#### 5. Test the Job

- Run `sh safe-shutdown.sh` to test the script.
- After powering on the Proxmox host again, check the log to make sure everything worked.