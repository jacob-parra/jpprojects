---
title: Memos
layout: default
---


<img src="/jpprojects/images/images/zima.png" class="float_img" alt="Zima">
<img src="/jpprojects/images/images/memos.png" class="float_img" alt="memos">

## Memos

Memos is a lightweight note taking app. Rather than a knowledge base note taking system, it's designed for fast, small notes, almost like google keep. It's very 

#### 1. Install Memos

In the app store, search for Memos. Click on it and click the drop down in the Install button to click Custom Install.

Under volumes, there will be one defualt mapping. Under the ZimaOS path, click the gray folder button, select your storage pool in the left side, and use the create folder button in the bottom left to create a `memos` folder.

Also, if you want, next to Environment variables, use the + ADD button to add another mapping. Set Key `MEMOS_INSTANCE_URL` to Value to (something like) `https://memos.home.lan`. (If you do this, set a Local DNS Record in Pi-hole that maps `memos.lan` to `<zimaip>:5230`, or to the reverse proxy for https termination (see the [nginx](/jpprojects/proxmox/proxmoxvms/nginx) project page.))

#### 2. Create the main user

Go to `<zimaip>:5230` or `https://memos.home.lan` to access the application. The first user you create will be the main/admin user.

After creating the admin account, login and begin taking notes.