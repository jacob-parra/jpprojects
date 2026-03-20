---
title: Jellyfin
layout: default
---

## Jellyfin Media Server

Jellyfin is a free, open-source media system that manages digital movie, tv show and music libraries streaming. Its a self-hosted Plex alternative. The server softeware is easy to configure with a web UI, and clients can connect and stream over the LAN or a VPN.

The following steps detail Jellyfin configuration, specifically for a movie streaming service:

#### 1. Install the server

Download <a href="https://repo.jellyfin.org/?path=/server/windows/latest-stable">here. </a>Run the .exe installer. Keep all the default options, except select the "Service" version, which is not the default.

#### 2. Configure the server and add your media

Once Jellyfin is installed, access the UI at <a href="http://localhost:8096">http://localhost:8096</a>. 

- Create an admin account
- Add a folder of media and configure the collection with desired settings (defaults are fine)

<div class="info">
A movie media folder can be easily ammassed by ripping content from DVDs. With an external optical drive, movies can be copied from DVDs via <a href="https://www.makemkv.com/">MakeMKV</a>, a ripper (transcoder) software. Movie `.mkv` files can then be compressed with <a href="https://handbrake.fr/">HandBrake</a> to optimize for space. The workflow can even be automatted. Further details can be found below.
</div>

#### 3. Connect your clients

Upon finishing setup, access Jellyfin from another device on the same LAN via a web browser : `http://<server_ip>:8096`

Login and begin streaming!

<hr>

The following steps are optional to further optimize a Jellyfin Server.

#### 4. Enable Hardware Transcoding

Hardware Encoding refers to optimization streaming capabilities of a media server by converting media files (video/audio) with a dedicated chip (GPU) rather than a CPU. It dramatically improves streaming quality, but can decrease stability.

While logged in as admin, navigate to the admin dashboard with the three line menu on the top. From the admin dashboard, navigate to the "Playback" > "Transcoding" section on from side-bar. Enable "Hardware Acceleration" and select the transcoding method that corrosponds with the machine's GPU (AMD, NVIDIA, Intel).

#### 5. Add additional users

While logged in as admin, navigate to the admin dashboard with the three line menu on the top. From the admin dashboard, navigate to the "Users" section on from side-bar. Use the "+" button to add a User. Upon setting a Name and Password, configure permissions (best-practice is to follow principles of zero-trust, which the defaults do). Ensure that "Allow remote connections to this server" to allow a user to log in over a VPN.

<hr>

### How to Rip

The following instructions detail the process of digitizing via the aforementioned method. NOTE: This workflow is optimized for DVDs. Digitizing BlueRays is fundamentally different and requires different hardware and different software and configuration.

#### 1. Download the Necessary Software

As described, this method relies on <a href="https://www.makemkv.com/">MakeMKV</a> for ripping and <a href="https://handbrake.fr/">HandBrake</a> for compression. Download both (they are free). 

Not software, but an external USB disc drive is also, obviously, needed.

#### 2. Rip

With the disc in the drive, start MakeMKV. The software will recognize the disc, and when recognized, click the drive icon to scan the disk. 

The disk scan will divide each "Title" and its metadata, audio and subtitles. There may be multiple "Titles" or copies of the actual movie, and several Titles may be extras or other, unecessary content. Select one of the large Title copies (It should be 10-20 GB larger than the rest) and deselect the rest. In that Title's dropdown menu, select an audio version and a subtitle option, probably in English. Look out for "Director's Commentary" and "For visually impaired" versions of the audio and subtitles, listed in details of in right partition of the software.

When the desired media is selected, specify a destination location. Then click the Make MKV button on the right. Ripping can take between 15 and 40 minutes depending on drive speed and media quality and size. 

#### 3. Compress

Moderate compression, especially of DVDs, can save nearly all the quality of the original media and reduce up to 50% file size. 

In Handbreak, open ("Open Source" button on the top menu) the ".mkv" created in the previous step. Then select the following options to optimize for quality and space:

- Summary Tab:
    - Format: MKV
    - Web Optimized: Off
    - Align A/V Start: On
    - Select a destination location at the bottom of the page 

- Video Tab:
    - Video Encoder: H.264 (Or a version that corrosponds to the Server Hardware Acceleration GPU transcoder version)
    - Framerate: Same as Source
    - Framerate mode: Constant
    - RF: 18
    - Encoder PReset: Slow
    - Profile/Level: Auto

- Filters Tab:
    - Decomb: Default (unless movie is an animation, then Off)
    - Every other option: Off

- Audio Tab
    - Codec: AC3 Passthru
    - Mixdown: Auto
    - Samplerate: Auto
    - Bitrate: Should be grayed out
    - Track Name: Surround 5.1

- Subtitles Tab
    - Source : English option (probably)
    - Forced Only: On
    - Burn in: Off

- Chapters Tab
    - Create chapter markers


If desired, these options can be set as a Preset. Click "Presets" in the top menu, then click "Add Preset". Name it and save. The preset will be saved under "Custom Presets" in the "Presets" list. Select the preset for every future file.

Upon proper configuration, click the green "Begin Transcoding" in the topmost menu. 

#### 4. Add to Jellyfin

Add the resulting .mkv file to Library folder listed in Jellyfin. Then on the Admin Dashboard, click "Scan all Libraries" to refresh listed media and make added files available for streaming. A few minutes may be needed to properly find and add all files and metadata.

<div class="info">
Note on  <a href="https://www.filebot.net/">FileBot</a>: Filebot is a tool that facilitates proper name formatting and metadata retrieval for movies and tv shows. It is optional, as all naming can be done manually and certain metadata is not strictly necessary. It requires a license to use, but can be a valuable tool especially for large digitizing projects or tv shows.
</div>