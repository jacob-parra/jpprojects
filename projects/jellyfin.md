---
title: Jellyfin
layout: default
---

Jellyfin is a free, open-source media system that manages digital movie, tv show and music libraries streaming. Its a self-hosted Plex alternative. The server softeware is easy to configure with a web UI, and clients can connect and stream over the LAN or a VPN.

The following steps detail Jellyfin configuration, specifically for a movie streaming service:

**1. Install the server**

Download <a href="https://repo.jellyfin.org/?path=/server/windows/latest-stable">here.</a>Run the .exe installer and keep the default options. 

**2. Configure the server and add your media**
Once Jellyfin is installed, access the UI at <a href="http://localhost:8096">http://localhost:8096</a>. 

- Create an admin account
- Add a folder of media and configure the collection with desired settings (defaults are fine)

<div class="info">
A movie media folder can be easily ammassed by ripping content from DVDs. With an external optical drive, movies can be copied from DVDs via  <a href="https://www.makemkv.com/">MakeMKV</a>, a ripper (transcoder) software. Movie `.mkv` files can then be compressed with <a href="https://handbrake.fr/">HandBrake</a> to optimize for space. The workflow can even be automatted.
</div>

**3. Connect your clients**

Upon finishing setup, access Jellyfin from another device on the same LAN via a web browser : `http://<server_ip>:8096`

Login and begin streaming!

<hr>

The following steps are optional to further optimize a Jellyfin Server.

**4. Enable Hardware Transcoding**

Hardware Encoding refers to optimization streaming capabilities of a media server by converting media files (video/audio) with a dedicated chip (GPU) rather than a CPU. It dramatically improves streaming quality, but can decrease stability.

While logged in as admin, navigate to the admin dashboard with the three line menu on the top. From the admin dashboard, navigate to the "Playback" > "Transcoding" section on from side-bar. Enable "Hardware Acceleration" and select the transcoding method that corrosponds with the machine's GPU (AMD, NVIDIA, Intel).

**5. Add additional users**

While logged in as admin, navigate to the admin dashboard with the three line menu on the top. From the admin dashboard, navigate to the "Users" section on from side-bar. Use the "+" button to add a User. Upon setting a Name and Password, configure permissions (best-practice is to follow principles of zero-trust, which the defaults do). Ensure that "Allow remote connections to this server" to allow a user to log in over a VPN.