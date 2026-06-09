---
title: Mealie
layout: default
---

<img src="/jpprojects/images/images/zima.png" class="float_img" alt="Zima">
<img src="/jpprojects/images/images/mealie.png" class="float_img" alt="Mealie">


## Mealie

Mealie is a self-hostable cookbook. It has a great UI for organizing recipies, and can even scrape recipies straight from websites.

#### 1. Install the app

In the Zima Dashboard, open the app store and search for Mealie. Click the app, click the down tab of the install button and click Custom Install.

I changed the mapping to put mealie on my storage pool. Change the mapping to be `/media/<storage pool>/Mealie` to `/app/data`. You can change the zima mapping by clicking the gray folder, navigating to your storage pool, and using the create a new folder button in the bottom left. If you do this, you may need to fix the permissions on that folder with `chown 911:911 /media/<storage pool>/Mealie` in the Zima host terminal.

I recommend changing the container name at the bottom of the config menu to something like "mealie". Leave the container IP to be the same as 

Then click the Install button at the bottom.

#### 2. Access the web console

Give the app a moment to install. Then click the app to launch it in another tab. 

The default admin credentials are `changeme@example.com` / `MyPassword`. Login and walk through the setup wizard, including changing the email and password.

