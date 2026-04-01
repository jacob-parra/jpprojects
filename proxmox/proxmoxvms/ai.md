---
title: Ollama AI
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">
<img src="/jpprojects/images/images/ollama.png" class="float_img" alt="Ollama">

## Ollama AI + Open WebUI

Ollama is a tool that facilitates self hosting LLMs. It is what actually runs the model. Open WebUI runs on top of Ollama and provides the sleek chat bot experience in the browser rather than the terminal. It handles user accounts and application administration and also manages chats. Ollama and Open WebUI are run in tandem to selfhost a chat bot.

These are the steps for creating an Ollama + Open WebUI application in a Proxmox Container:

#### 1. Download the Container template

In your Proxmox node, go to the server storage (probably called "local"). Go to CT Templates in the interior left menu, and click Tempaltes at the top. Search for Debian, and select the Debian 12 template. Click Download.

#### 2. Create the Container

Click the blue Create CT button in the top right. 

- General
    - Set the CT ID
    - Set the Hostname ("Ollama")
    - Set and confirm the container password (ollama)
- Template
    - Select your Debian template from the last step
- Disks
    - Set Disk Size to 100
- CPU
    - Set 3-4 Cores
- Memory
    - Set memory to 12288
    - Set swap to 4096
- Netowrk
    - Set IP with CIDR subnet mask
    - Set Gateway
- DNS
    - Do nothing

Confirm everything is correct, and click Finish.

#### 3. Additional Settings

In Proxmox, select the container in the left menu. Go to Options, click Features and click Edit in the top menu. Check both the keyctl and Nesting boxes, and click OK.

Next, we need to enable docker support in our continaer. In the Proxmox host shell, edit the container conf file:

`nano /etc/pve/lxc/<CT ID>.conf`

Make sure the file has the following lines:

```
features: nesting=1,keyctl=1
lxc.apparmor.profile: unconfined
lxc.cgroup2.devices.allow: a
lxc.cap.drop:
```

#### 4. Install Docker & Compose

Start the container. In the container console, run these 4 commands to install Docker and Docker Compose.

- `apt update && apt upgrade -y`
- `apt install -y docker.io docker-compose`
- `systemctl enable docker`
- `systemctl start docker`

Check that everything is running ok with `systemctl status docker`.

#### 5. Create the Project Structure

Create the folders:

- `mkdir -p /opt/ai-stack`
- `cd /opt/ai-stack`
- `mkdir -p ollama open-webui scripts`

This is where the project will live.

#### 6. Create the Docker Compose File

While still in `/opt/ai-stack`, create the docker compose file with `nano docker-compose.yml`. Add this in there:

```
version: "3.9"

services:
  ollama:
    image: ollama/ollama
    container_name: ollama
    restart: unless-stopped
    ports:
      - "11434:11434"
    environment:
      - OLLAMA_NUM_THREADS=4
      - OLLAMA_MAX_LOADED_MODELS=1
      - OLLAMA_KEEP_ALIVE=5m
    volumes:
      - ./ollama:/root/.ollama

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "3000:8080"
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    depends_on:
      - ollama
    volumes:
      - ./open-webui:/app/backend/data
```

Then Start everything with `docker-compose up -d`. It will take a while to pull and start (Theres more than a GB of stuff to download). You should be able to access it at `<container ip>:3000`.

#### 7. Pull a Model

In the same directory as before, pull Mistral (an AI model): `docker exec -it ollama ollama run mistral`.

This is the model the chat bot will actually use.

This is the structure of the application within the container now:

```
/opt/ai-stack/
├── docker-compose.yml
├── ollama/              ← (Models live here)
│   └── (model files)
├── open-webui/          ← (Chat database)
│   └── (sqlite + uploads)
└── scripts/
```

#### 8. Create the Admin Account

The first account you create at the web interface will be the Admin account. Set the Full name, email and password.

This is now essentially a self hosted AI chatbot. It will likely be much slower than commercial chatbots, but its 100% local and self-owned.

<hr>

## Scripts

These optional scripts can facilitate managment of the application and its data.

#### 9. Wipe Script

A wipe script can delete all data, and can be synced to a cronjob to keep the container disk from filling up. Create the script with `nano /opt/ai-stack/scripts/clear-chats.sh` and add this:

```
#!/bin/bash

echo "Stopping Open WebUI..."
docker stop open-webui

echo "Deleting chat database..."
rm -rf /opt/ai-stack/open-webui/*

echo "Restarting Open WebUI..."
docker start open-webui

echo "All chats cleared."
```

Make the script executable: `chmod +x /opt/ai-stack/scripts/clear-chats.sh`.

Run anytime to wipe all chats: `/opt/ai-stack/scripts/clear-chats.sh`.

<div class="info">
Note: Using this script will require you create a new admin account, as ALL data is deleted.
</div>

#### 10. Start/Stop commands

In case the app turns off or needs to be restarted, use these docker commands:

- Start: `cd /opt/ai-stack` and `docker-compose up -d`
- Stop: `cd /opt/ai-stack` and `docker-compose down`

#### 11. Aliases.

These scripts can be mapped to aliases so that they can be run with a single command from anywhere in the container.

Edit the shell config file: `nano ~/.bashrc`. At the very bottom, add the aliases:

```
# AI stack shortcuts
alias ai-start="cd /opt/ai-stack && docker-compose up -d"
alias ai-stop="cd /opt/ai-stack && docker-compose down"
alias ai-wipe="/opt/ai-stack/scripts/clear-chats.sh"
```

Activate the aliases with `source ~/.bashrc`.

Now use `ai-start` to start the application, or `ai-stop` to stop it.