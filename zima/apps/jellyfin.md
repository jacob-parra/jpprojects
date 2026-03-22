---
title: Jellyfin
layout: default
---

## Jellyfin Media Server as a Docker App in Zima

Jellyfin is a free, open-source media system that manages digital movie, tv show and music libraries streaming. It's a self-hosted Plex alternative. The server softeware is easy to configure with a web UI, and clients can connect and stream over the LAN or a VPN.

The following steps detail Jellyfin configuration, specifically for a movie streaming service:

#### 1. Install Jellyfin

Enter the "App Store" app on the dashboard. Search and install "Jellyfin". Let it finish installing (it will not be grayed out when finished, and a banner will notify you).

#### 2. Initial Settings

After installing, click the 3 dots in the top right corner of the Jellyfin App and go to Settings.

- Set the Web UI port to be `8096` (the dault for Jellyfin).
- Set the Ports for both the Host and the Container to be `8096` as well.
- Under Environment Variables, make sure both PGID and PUID are set to `1000` (this is the service account Jellyfin runs with).

#### 3. Configure Volumes

This is where stuff gets tricky. I recommend creating a folder in your storage pool called something like "Movies". This can be done by opening the "Files" app in the dashboard, clicking on your storage pool in the left bar, and right clicking to create a folder. This folder is needed for this part, where we map files of the Zima host to Jellyfin.

While still in the settings for the Jellyfin App, set these mappings:

- **Host** : /DATA/AppData/jellyfin/config
    - **Jellyfin** : /config
- **Host** : /media/`<storage pool>`/`Movies` 
    - **Jellyfin** : /Media
- **Host** : /opt/vc/lib
    - **Jellyfin** : /opt/vc/lib

If these mappings are not correct Jellyfin is not gonna work. When setting the host paths, use the little folder button to select the path (to avoid making Jellyfin mad).

Click Save at the bottom to finish.

#### 4. Setup

Click the Jellyfin app icon in the dashboard to open it in a new tab. This will take you to the setup wizard. Here you will

- Create an admin account
- Add a folder of media and configure the collection with desired settings (defaults are fine)

After initial setup and loggin in, more settings can be accessed by clicking the 3 line menu in the top left, and clicking Dashboard under Administration. You can also add user accounts here.

<hr>

More details on configuring the Server, as well as instructions for digitizing a physical media library, can be found on the [Jellyfin Project Page](/jpprojects/projects/jellyfin).

