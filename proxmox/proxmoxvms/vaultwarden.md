---
title: Vaultwarden
layout: default
---
## Vaultwarden

Vaultwarden is an open-source, self-hosted password manager server that is fully compatible with the official Bitwarden client apps (browser extensions, phone apps, etc.). It's very lightweight, and enables local password management without relying on or paying for third-party cloud servers.

Vaultwarden is so lightweight that it can actually be hosted as a container in Proxmox (like a VM, but interacts differently with the host, are much faster and very cheap on resources). Ideally, it can be hosted natively, directly as the container "OS". But in actuality it's easier to configure inside Docker.

<div class="info">
Creating and configuring the Vaultwarden container itself is relatively simple. However, Vaultwarden requires HTTPS, which requires SSL certificates. There are lots of ways to get these certificates that range in difficulty, from self-signed to reverse proxy distributed. I opted to use Caddy, a reverse proxy service that can manage cert rotation automatically. It's very easy to use, and can be ran in tandem with Vaultwarden in Docker. It's a good setup
</div>

**1. Add the Container Template**

Proxmox is cool, and has a list of a bunch of popular container readily available for download. 

In your Proxmox host, go to your Nodes storage, probably called "local", in the left menu. Then go to CT Templates. Click the Templates button at the top, and find `debian-12-standard_12.12-1_amd64.tar.zst`. Click the Download button and wait for it to download to your host.

**2. Create the Container**

Click the blue Create Container button at the top right of Proxmox.

- General
    - Set the Container ID (CT ID)
    - Set a host name
    - Set a password for the container
    - Uncheck Unprivileged container
- Template
    - Add the Debian template from the last step
- Disk
    - Give 8-16 GB
- Cores
    - Leave 1 core (or 2, if you can afford it)
- RAM
    - Give 1024 MiB
- Network
    - Leave the Name and Bridge (but make sure the bridge is the LAN one, if you have multiple)
    - Set an IPv4 address and gateway, but leave IPv6 blank
- DNS
    - Leave both options as "use host settings"

Confirm everything is correct, then hit Finish.

Once the container is created, click on it in the left menu, and go to Options. Click on the "Start at boot" option and check the box, so that the container turns on with Proxmox. While here, click on the "Features" option and check the "Nesting" box. This is required for Docker.

**3. Install Docker**

- Update and Upgrade : `apt update && apt upgrade -y`
- Install Docker : `apt install docker.io docker-compose -y`
- Enable and Start : `sytemctl enable docker` and `systemctl start docker`

**4. Create the Vaultwarden Directory**

This is where all the Vaultwarden files will be kept, including the docker-compose.yaml and Caddy File.

- Create the directory : `mkdir -p /opt/vaultwarden`
- Go there : `cd /opt/vaultwarden`

**5. Create the Configuration Files**

While in the Vaultwarden Directory, create the following file: `nano docker-compose.yml`

```
version: "3.8"

services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    expose:
      - "80"
    volumes:
      - ./vw-data:/data
    networks:
      - internal

  caddy:
    image: caddy:2-alpine
    container_name: caddy
    restart: unless-stopped
    ports:
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - internal

volumes:
  caddy_data:
  caddy_config:

networks:
  internal:
```

While in this same directory, also create the Caddyfile (which holds the Caddy configuration): `nano Caddyfile`

```
vaultwarden.local {
    tls internal
    reverse_proxy vaultwarden:80
}
```

**6. Start the Docker Container and Extract the Cert**

While in this same directory, bring up the project with `docker compose up -d`.

Caddy stores the certificate inside the Docker volume. Make sure it is there: `cocker exec caddy ls /data/caddy/pki/authorities/local`.

Copy it out: `docker cp caddy:/data/caddy/pki/authorities/local/root.crt ./caddy-root.crt`. The certificate will be in this directory in the `caddy-root.crt` file. 

**7. Install the Certificate**

The certificate from the last step needs to be installed on every device you would like to access Vaultwarden from (a downside to using self-signed certificates). The certificate can be extracted from Proxmox with an scp command (from the Vaultwarden container console): `scp caddy-root.crt <username>@<remoteip>:`

These are the steps for installing the certificate on both Mac and Windows. 

#### Mac

1. Open Keychain Access by opening the Spotlight Search (`Cmd + Space`) to find Keychain Access. Open it.
2. Import the Certificate by going to System in the left sidebar. The go to `File → Import Items` and select the `caddy-root.crt` file. Enter your Mac password if necessary
3. Trust the imported certificate by double clicking it, expanding Trust, and set "When using this certificate → Always Trust"

#### Windows

1. Open Notepad as Admin (by right clicking the app and selecting "Run as Administrator"). Click `File → Open` and paste this into the filename box at the bottom: `C:\Windows\System32\drivers\etc\hosts`. After the file opens, add this line to the bottom of the file: `<Vaultwarden Tailscale IP>  vaultwarden.local`. 
2. Double click on thye `caddy-root.crt` file. Click "Install Certificate". Choose "Local Machine". Select Place all certificates in the following store". Click "Browse" and choose "Trusted Root Certification Authorities". Then click Finish.

After installing the certificate on your device, relaunch your browser for the change to take affect. Visit `https://vaultwarden.local`. It should resolve properly. If your browser warns you about visiting the site, click "advance to vaultwarden.local" to ignore it.

**8. Access the Web App**

Once you've reached the Web App you will be asked to create an account. Use your email and set a strong master password, necessary to unlock your vault.

Once you are in 


Install the Cert on iPhone:
- Download the cert
- Search Profile Downloaded
- Tap install, use password, and install
- Go to General->about->Certificate Trust Settings, enable the cert and hit continue