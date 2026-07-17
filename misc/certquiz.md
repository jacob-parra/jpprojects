---
title: Certquiz
layout: default
---
## Certquiz

In preparing for the various cybersecurity certifications (like the Comptia Network + and Security +) I was dissapointed by the free online practice test and study options, and even more dissapointed by how expensive the paid options were. So I used Claude AI to help me build an App I designed to make studying for certs feel like Duolingo.

Certquiz is a self hosted web app that runs in Docker. I have it running in a Debian container in my Proxmox server.

#### 1. Create the Debian Container

Details for deploying a Debian container with Docker installed in Proxmox can be found [here](/jpprojects/proxmox/proxmoxvms/docker).

#### 2. Download Certquiz

The zip file is available here.

Use scp to move the zip to the container (run this command from the downloads directory): `scp certquiz.zip root@<container ip>:`.

Install the unzip utility with `apt install unzip` and unzip: `unzip certquiz.zip`.

#### 3. Build and Deploy

First, generate a secure token with wich login cookies will be signed: ``. Copy the random string that command produces.

Move into the new certquiz directory: `cd certquiz`.

Edit the yaml file (``) and put the random string here: Please tell me this worked