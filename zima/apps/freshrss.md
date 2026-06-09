---
title: FreshRSS
layout: default
---

<img src="/jpprojects/images/images/zima.png" class="float_img" alt="Zima">
<img src="/jpprojects/images/images/fresh.png" class="float_img" alt="Fresh RSS">


## Fresh RSS

Fresh RSS is a self-hostable RSS reader. RSS is a method for websites to publish updates in a feed format. Fresh RSS is the application that receives the updates and consolidates them into a feed. Fresh RSS lets you read that feed in a web app, or mobile apps can connect to the container for nice mobile reading too.

#### 1. Install Fresh RSS

In the Zima Dashboard, click the App Store and search for Fresh RSS. Click on it, use the dropdown on the isntall button to hit the Custom Install button. 

- Set TZ to your time zone (I used `America/Denver`).
- Set the Web UI IP address to be the IP of the host.
- For the Volume mappings, I created a new folder on my pool named `FreshRSS`, and created a Data and Extensions folder there, and mapped each to `/var/www/FreshRSS/data` and `/var/www/FreshRSS/extensions` in the container.
- Leave the rest default

Click the install button at the bottom. Give it a moment to start up, and then click the app in the dashboard.

#### 2. Finish Installation

Walk through the installation in the web app (at `http://<host ip>:8749`). You'll set the language, make sure everything is set up correctly, and select a database type (I don't think it matters what you pick). You'll also set up the default user and password.
