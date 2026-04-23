---
title: Actual Budget
layout: default
---


<img src="/jpprojects/images/images/zima.png" class="float_img" alt="Zima">
<img src="/jpprojects/images/images/actualbudget.png" class="float_img" alt="Actual Budget">

## Actual Budget

Actual Budget is a personal finance app that facilitates envelope-style budgeting and spending tracking.

#### 1. Install the app

In the Zima Dashboard, open the app store and search for Mealie. Click the app, click the down tab of the install button and click Custom Install.

I changed the mapping to put mealie on my storage pool. Change the mapping to be `/media/<storage pool>/ActualBudget` to `/app/data`. You can change the zima mapping by clicking the gray folder, navigating to your storage pool, and using the create a new folder button in the bottom left. If you do this, you may need to fix the permissions on that folder with `chown 911:911 /media/<storage pool>/ActualBudget` in the Zima host terminal.

I recommend changing the container name at the bottom of the config menu to something like "mealie". Leave the container IP to be the same as 

Then click the Install button at the bottom.

#### 2. Acess the web console

Click on the app icon to open it in a new tab. A pop up will tell you to ignore the start up failure alert. Proceed and do just that. 

You'll set the password that is used to login to this app.