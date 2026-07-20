---
title: Certquiz
layout: default
---
## Certquiz

In preparing for the various cybersecurity certifications (like the Comptia Network + and Security +) I was disapointed by the free online practice test and study options, and even more dissapointed by how expensive the paid options were. So I used Claude AI to help me build an App I designed to make studying for certs feel like Duolingo.

Certquiz is a self hosted web app that runs in Docker. I have it running in a Debian container in my Proxmox server.

#### 1. Create the Debian Container

Details for deploying a Debian container with Docker installed in Proxmox can be found [here](/jpprojects/proxmox/proxmoxvms/docker).

#### 2. Download Certquiz

The zip file is available [here](/jpprojects/downloads/certquiz.zip).

Use scp to move the zip to the container (run this command from the downloads directory): `scp certquiz.zip root@<container ip>:`.

Install the unzip utility with `apt install unzip` and unzip: `unzip certquiz.zip`. Move into the directory: `cd certquiz`.

#### 3. Change the Secure Token

First, generate a secure token with wich login cookies will be signed: `python3 -c "import secrets; print(secrets.token_hex(32))"`. Copy the random string that command produces.

Move into the new certquiz directory: `cd certquiz`.

Edit the yaml file (`docker-compose.yml`) and put the random string at this line: `SESSION_SECRET=`. Ctrl+O and Ctrl+X to save and exit.

#### 4. Build and Deploy

```
docker compose build
docker compose up -d
```

The app should then be available at `http://<container IP>:8000`.

If not, check the logs for errors with: `docker compose logs -f certquiz`.