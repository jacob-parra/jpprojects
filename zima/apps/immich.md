---
title: Immich
layout: default
---

## Immich Photo Server as a Docker App in Zima

Immich is a self-hosted image server. It acts as a substitute for Google Photos and has both browser and iOS/Android apps. It's robust and full of features, while still being very slick and user friendly.

These are the steps for configuring an Immich server as a Docker app in Zima:

#### 1. Install Immich

Enter the "App Store" app on the dashboard. Search and install "Immich". Let it finish installing (it will not be grayed out when finished, and a banner will notify you).

#### 2. Create the Upload Folder

This step is taken care of when the app installs, but I found that the upload folder is usually created on the same disk as the app, which is usually the disk where the Zima host is. You probably don't want that, because this is where all of your images will be uploaded to and it will quickly fill up your host disk.


Instead (These commands are to be run as an admin in the Zima terminal), create the folder manually on your RAID pool: 
- `sudo mkdir -p /media/<pool name>/immich`

Create the subfolders:
- `sudo mkdir -p /media/<pool name>/immich/{library,upload,thumbs,encoded-video,profile,backups}`

Create marker files: 
- `sudo touch /media/<pool name>/immich/{library,upload,thumbs,encoded-video,profile,backups}/.immich`

Recursivley fix all permissions: 
- `sudo chown -R 1000:1000 /media/Nublado/immich`
- `sudo chmod -R 755 /media/Nublado/immich`


#### 3. Initial Settings

After installing, click the 3 dots in the top right corner of the Jellyfin App and go to Settings.

Click on the "immich-server" tab at the top of the settings menu. We need to map the upload folder of the host to the Immich container like this:

```
       Zima Host                          Immich
/media/Nublado/Immich       →       /usr/src/app/upload
```

Immich will handle where exactly to put uploaded content from there, as long as you created the necessary subfolders correctly in Step 2.

Click the blue Save button at the bottom right.

#### 4. Start and Create the Admin

Immich will take a moment to check the configurations and load, and the app may be grayed out temporarily to do so. When it comes back on, click it to open in a new browser.

Your first user created will be the admin user. Set the email, password and name for the admin account. Don't forget this password! It is very difficult to reset!(I didn't manage to do it).

<div class="info">
Each email can only be associated with 1 email address, so if you use your personal email consider this both the admin account and your user account.
</div>

#### 5. Login and Wizard

Login with your admin account you just made. You'll be walked through an initial setup wizard:

- Choose the theme (dark/light)
- Set the language
- Set "Map" and "Version Check" security settings
- Set User Privacy ("Google Cast") setting
- It is highly recommended to enable "Storage Template Engine", to facilitate storage organization.

#### 6. Add Users

When you log it, click on your profile image in the top right and click Administration. This takes you to the admin page.

Here, make sure you are in the "Users" tab in the left menu. On the top right, click Create User. You set the Email, Initial Password and Name for the account. The Quota size is how much storage the user is allowed to use. Finish by clicking create at the bottom. The user will be able to login and use Immich.

<hr>

### Helpful Links
- [Official Tutorial](https://www.zimaspace.com/docs/zimaos/Immich-Tutorial)
- [Enable Machine Learning Features](https://www.reddit.com/r/immich/comments/1j7qolt/need_a_little_help_with_remote_machine_learning/)