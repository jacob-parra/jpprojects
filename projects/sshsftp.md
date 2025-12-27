---
title: SSH & SFTP
layout: default
---

## SSH & SFTP

SSH (Secure Shell) is a protocol that allows secure remote console connection into another machine. SFTP (Safe File Transfer Protocol) is a protocol that securely move files between machines remotely.

These commands and instructions detail SSH & SFTP configuration.

**1. Install the SSH Server**
Run PowerShell as an admin, and run this command `dism /online /Add-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0`

**2. Start the SSH Server**
`Start-Service sshd`

**3. Make SSH start automnatically on boot**
`Set-Service -Name sshd -StartupType Automatic`

**4. Confirm SSH is running**
`Get-Service sshd`
You should see
`Status: Running`
`StartType: Automatic`

**5. Configure the Firewall**
This command allows TCP traffic through port 22 (the default SSH port)
`New-NetFirewallRule -Name sshd -DisplayName "OpenSSH Server" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22`

SSH should be good to go. It can be tested by using this command from another machine on the same LAN (or Tailscale network) `ssh username@machineIp` 

<div class="info">
Find your machineIp using `ipconfig`. Locate the IPv4 section of the output, the IP will probably look like `192.168.x.x`
</div>

The ssh command will ask to receive a fingerprint and confirm connection. Type "yes" and enter, and enter your Username password when prompted. The terminal should show something like `username@machineName C:\Users\username>`, indicating that ssh was successful. You are now interacting with the terminal of the hosting machine.

Conveniently, the OpenSSH server used for SSH also supports SFTP. The connection is very similar: `sftp username@machineIp`. Once the connection is established, files can be safely transferred between a remote machine and the server machine with the following commands:


**put**

The `put` command is used to transfer a file from the remote (connecting) machine to the server machine. This is the command template:
`put remote/file/path [server/path]` 
Note that the first file path is the path of the file on the remote machine, and the (optional) destination path is on the server machine.

**get**

The `get` command is used to transfer a file from the server machine to the remote machine. This is the command template:
`get server/file/path [remote/path]`
Note that the first file path is the path of the file on the server machine, and the (optional) destination path is on the remote machine.