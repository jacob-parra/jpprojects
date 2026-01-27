---
title: OpenSSH
layout: default
---

## OpenSSH

OpenSSH is a free, open source SSH server that can be installed on individual VM's to allow for remote, direct terminal connection. It's simple to install and lightweight.


**1. Install OpenSSH**

- Run `sudo apt update` to make sure everything is up to date
- Install with `sudo apt install -y openssh-server`
- Check the status with `sudo systemctl status ssh`. It should already be running. If not, do `sudo systemctl enable --now ssh`.
