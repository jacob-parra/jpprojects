---
title: Mint
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">
<img src="/jpprojects/images/images/nginx.png" class="float_img" alt="Nginx">

## Nginx

Nginx is a reverse proxy, which I use to terminate HTTPS in my lab.

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

#### 6. Create Pi-hole redirect rule

Use Pi-hole for DNS to redirect queries to `https://servicename.home.lan` to nginx for port forwarding and HTTPS termination. 

In Pi-hole, go to `Settings > Local DNS Records` in the left menu. Under Local DNS records, fill in the Domain and Associated IP, and click the green + button to add a record. (For example, set Domain to notes.lan and Associated IP to the nginx server IP address).

#### 7. Distribute rootCA.pem to client devices

The easiest way is to output the CA (`cat /root/.local/share/mkcert/rootCA.pem`) and copy-paste it to another device. Or you can use `cp` to move it to another device.

To install the CA:
- On Windows : Press Win + R and run certmgr.msc. In the left panel, expand Trusted Root Certification Authorities, right click Certificates. Go to All Tasks > Import. Browse to the .crt file, select Place all certificates in the following store (should be set to Trusted Root Certification Authorities) and click Finish. It should be listed as `mkcert root@ngninx`.
- On Windows : Press win + r and type mmc, and hit ok. Go to File > Add/Remove Snap-in. Find Certificates on the left and click Add. Select Computer Account, Next and Finish.
- On macOS: double-click → Keychain Access opens → right-click → Get Info → Trust → Always Trust