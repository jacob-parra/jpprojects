---
title: Nginx
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">
<img src="/jpprojects/images/images/nginx.png" class="float_img" alt="Nginx">

## Nginx

Nginx is a reverse proxy, which I use to terminate HTTPS in my lab. Rather than create a cert for every service, I used a wildcard cert that works with any service domain name. Pi-hole is used for Local DNS Records to point my domains (like notes.parra.lan or immich.home.lan) to nginx for https termination. Nginx then redirects the traffic to the appropriate service. 

<div class="info">
Every service that uses ngninx needs it's own configuration file in the nginx container, and every client device that will connect to services through ngninx needs to trust the nginx Certificate Authority. 
</div>

There are 2 ways to configure nginx: in the command line, or with a gui (Nginx Package Manager). I started on the command line, and then transitioned to NPM. If I were to do this again, I would just go straight to NPM. If you do so, you still need to do steps 1, 3, 4, and 6 from the CLI instructions first, and step 7 afterwards.

These are the instructions for creating an nginx reverse proxy server. 

## Nginx in the Command Line

#### 1. Create the container

- General
    - Give the container a CTID
    - a hostname
    - and a password
- Template
    - Select the Debian Template
- Disks
    - 4 GB is fine
- CPU
    - Set 1 core
- Memory
    - 256 MG is fine
- Network
    - Set a static IP address
    - Set a gateway
- DNS
    - Set the DNS server IP, or leave it blank to use the host settings

Confirm and click Finish on the last tab

Then right click and start the container, and login with username `root` and the password you just set.

#### 2. Install nginx

First upgrade and update : `apt update && upgrade -y`.

Then install nginx (and some other utilities): `apt install -y nginx libnss3-tools curl`.

Make sure nginx is running with `systemctl status nginx`. You should see `active (running)`.

#### 3. Install mkcert and create the CA

Install the latest mkcert binary: `curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64`.

Make it exectuable : `chmod +x mkcert-v*-linux-amd64`.
Move it to PATH so it is permanently accessible : `mv mkcert-f*-linux-amd64 /usr/local/bin/mkcert`

Then, create the local Certificate Athority : `mkcert -install`.

This will create two files (in a directory which can be found with `mkcert -CAROOT`): `rootCA.pem` is the certificate that gets installed onto all client devices `rootCA-key.pem` stays on this machine.

#### 4. Generate the Wildcard Cert

This cert will be used to terminate HTTPS for every connection that goes through nginx. 

First, create a dedicated directory to help keep things tidy: `mkdir -p /etc/nginx/certs`. Go there: `cd /etc/nginx/certs`.

Then, issue the wildcard cert: `mkcert "*.home.lan" "home.lan"`.

<div class="info">
Note: You NEED to have at least 1 subdomain. As in, browsers will freak out if you try to do service.lan, but service.home.lan is ok.
</div>

This will create two files again:
1. The cert : `/etc/nginx/certs/_wildcard.home.lan+1.pem`
2. The key : `/etc/nginx/certs/_wildcard.home.lan+1-key.pem`

#### 5. Create and enable Config Files

Each service that uses nginx for HTTPS termination needs its own config file. This is a template that can be used for each service, with minor modification.

Create the file : `nano /etc/nginx/sites-available/<servicename>`

```
server {
    listen 80;
    server_name <servicename>.home.lan;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name <servicename>.home.lan;

    ssl_certificate     /etc/nginx/certs/_wildcard.home.lan+1.pem;
    ssl_certificate_key /etc/nginx/certs/_wildcard.home.lan+1-key.pem;

    location / {
        proxy_pass http://<service ip address and port>;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the configuration and reload:
- Enable: `ln -s /etc/nginx/sites-available/memos /etc/nginx/sites-enabled/`
- Test for config errors: `nginx -t`
- Reload: `systemctl reload nginx`

#### 6. Distribute rootCA.pem to client devices

The easiest way is to output the CA (`cat /root/.local/share/mkcert/rootCA.pem`) and copy-paste it to another device. Or you can use `cp` to move it to another device.

To install the CA:
- On Windows : Press Win + R and run certmgr.msc. In the left panel, expand Trusted Root Certification Authorities, right click Certificates. Go to All Tasks > Import. Browse to the .crt file, select Place all certificates in the following store (should be set to Trusted Root Certification Authorities) and click Finish. It should be listed as `mkcert root@ngninx`.
- On macOS: double-click → Keychain Access opens → (you may need to search for it: "mkcert root@ngninx") right-click → Get Info → Expand Trust → Always Trust
- On iPhone: I airdropped the CA file to my phone (but you can email it to yourself and download). Then in settings, I went to settings, and found a button at the top that said Profile Downloaded. There I clicked Install, put in my password and clicked install again.

#### 7. Create Pi-hole redirect rule

Use Pi-hole for DNS to redirect queries to `https://servicename.home.lan` to nginx for port forwarding and HTTPS termination. 

In Pi-hole, go to `Settings > Local DNS Records` in the left menu. Under Local DNS records, fill in the Domain and Associated IP, and click the green + button to add a record. (For example, set Domain to notes.lan and Associated IP to the nginx server IP address).

<hr>

## Nginx Package Manager (GUI)

Like I said, I built this in the same container as the nginx CLI project, and I used the same CA/certs. These first few steps are a bunch of copy/paste in the terminal in order to bring the web console up.

#### 1. Install Docker and Dependencies 

- Install dependencies
    - `apt update`
    - `apt install -y ca-certificates curl gnupg`
- Add Docker's official GPG key
    - `install -m 0755 -d /etc/apt/keyrings`
    - `curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg`
    - `chmod a+r /etc/apt/keyrings/docker.gpg`
- Add the Docker apt repository
    - `echo \ "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \ https://download.docker.com/linux/debian \ $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \ tee /etc/apt/sources.list.d/docker.list > /dev/null`
- Install Docker and Compose
    - `apt update`
    - `apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
- Check that it worked
    - `docker --version`
    - `docker compose version`

#### 2. Pause existing nginx service

- Stop nginx : `sudo systemctl stop nginx`
- Prevent nginx from running on start : `sudo systemctl disable nginx`

#### 3. Create the NPM Docker Compose file

- Create a directory for NPM to live in:
    - `bashsudo mkdir -p /opt/npm`
    - `cd /opt/npm`
- Create the compose file:
    - `nano docker-compose.yml`

Paste this into the compose file:

```
services:
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "81:81"
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```

Save and exit with  `Ctrl+O`, `Enter` and `Ctrl+X`. Port 81 is NPM's web UI. Ports 80 and 443 are the actual proxy ports.

#### 4. Start NPM

Navigate to the NPM folder : `cd /opt/npm`
Start the container : `docker compose up -d`
Check it's running : `docker compose ps`
Make docker run on start : `enable docker` (the service is already set to run on start).

You should see the container with status Up. Give it 30 seconds to fully initialize, then open a browser and go to:

http://<container-ip>:81

Create the admin credentials: nginxproxyadmin

#### 5. Upload Wildcard Cert and Key

The cert and key are in `cd /etc/nginx/certs`. You need to download them to then upload them to the GUI.

In the web GUI, go to Certificates in the top bar. Click Add Certificate, and then Custom Certificate. Upload both the key and certificate files and click save.

#### 6. Create the Proxy Hosts

Use the information from the CLI config files to create the proxy hosts in the GUI. 

In the GUI, go to `Hosts > Proxy Hosts` and click Add Proxy Host. Fill in the details:

In the Details tab :
- Domain Names: the hostname, e.g. `<service>.home.lan`
- Scheme: http or https depending on the upstream service (if you don't know which to use, test with both)
- Forward Hostname/IP: the internal IP of the service
- Forward Port: the port the service runs on
- Enable Block Common Exploits — good default to have on


Click the SSL tab:
- Select your uploaded cert from the dropdown
- Enable Force SSL (redirects HTTP → HTTPS automatically)

Click Save

You should be able to access `https://<service>.home.lan` without issue.

### Proxy configurations by service:

These are the some ofconfigurations I used for different services in NPM.

**OPNsense**
- Scheme : https
- Forward Port : 443
- Custom Nginx Configuration : 
```
proxy_ssl_name OPNsense.internal;
proxy_ssl_server_name on;
proxy_ssl_verify off;
```
- Notes : I also had to set an Alternate Hostname in the OPNsense console (`System > Settings > Administration`) to match the Pi-hole local DNS record and NPM Domain Name.

**Proxmox**
- Scheme : https
- Forward Port : 8006
- Websockets Support : Enabled

**Wazuh**
- Scheme : https
- Forward Port : 443

**Pi-hole**
- Scheme : http
- Forward Port : 80
- Custom Nginx Configuration
```
location = / {
    return 301 /admin/login;
}
```

**Nginx**
- Scheme : http
- Forward Port : 81