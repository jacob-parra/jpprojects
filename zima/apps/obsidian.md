---
title: LiveSync Obsidian
layout: default
---

<img src="/jpprojects/images/images/zima.png" class="float_img" alt="Zima">
<img src="/jpprojects/images/images/obsidian.png" class="float_img" alt="Obsidian">

## Obisidan LiveSync Server

Obsidian is a Markdown note taking app / personal knowledge base. It is heavily supported with lots of community plugins. Rather than saving and editing files in Obsidian on your machine, the LiveSync plugin lets files be edited and synced to an external database. This LiveSync Server is actually run as a CouchDB container in Zima. Obsidian is run natively on your devices and points to the server as the storage location. This keeps the file editing quick and smooth while not taking storage on your device.

<div class="info">
I did this project without HTTPS, which won't let obsidian apps on mobile connect to this LiveSync server. Maybe I will go back and change this later, but it works fine for my purposes for now.
</div>

This is how to create a LiveSync CouchDB container on ZimaOS

#### 1. Create the Container

On the Zima dashboard, click the + button on the top right and click "Install a customized app" to create the container. 

- Set Docker image to `couchdb`
- Set Tag to `latest`
- Set Title to CouchDB
- Set the WEB UI to be the same IP as the ZIMA host itself, and the port to :5984
- Make sure Network is set to `bridge`.
- To the right of Ports, click the "+ ADD" button:
    - Set both Host and Container ports to `5984`, Protocol TCP
- To the right of Volumes, click the "+ ADD" button twice:
    - Set ZimaOS to `/media/<pool name>/CouchDB/data` and CouchDB to `/opt/couchdb/data`.
    - Set ZimaOS to `/media/<pool name>/CouchDB/config` and CouchDB to `/opt/couchdb/etc/local.d`.
        - (actually, this should probably live on the ssd... but it's so lightweight it probably doesn't actually matter, in reality.)
- To the right of Environment Variables, click the "+ ADD" button twice:
    - Set Key to `COUCHDB_PASSWORD` and Value to `<your admin password>`
    - Set Key to `CHOUCHDB_USER` and Value to `<your admin username>`
    - Note : This will be the only user for this container.
- At the very bottom, set the container name to something like `couchdb`

Click the blue save button.

#### 2. Prepare the Directories.

While on the Dashboard, click the settings gear on the top left and go to `General > Developer Mode > Web-based terminal` to reach a terminal for the Zima Host. Login.

Run these commands to create the folders assigned in the last step:
- `mkdir -p /Nublado/CouchDB/data`
- `mkdir -p /Nublado/CouchDB/config`

Run these commands to set the Owner and Group for those folders
- `chown -R 5984:5984 /Nublado/CouchDB/data`
- `chown -R 5984:5984 /Nublado/CouchDB/config`

Run these commands to set the permissions for those folders
- `chmod -R 755 /Nublado/CouchDB/data`
- `chmod -R 755 /Nublado/CouchDB/config`

#### 3. Initialize for LiveSync

Right now this is just a generic database container. To get it to run as a LiveSync server, it needs to be initialized as such. This commands does that in one go:

`curl -s https://raw.githubusercontent.com/vrtmrz/obsidian-livesync/main/utils/couchdb/couchdb-init.sh | hostname=http://<ip>:5984 username=<username> password=<password> bash`

<div class="info">
'ip' should be the IP address of the Zima host, as set in step 1. 'username' and 'password' are also the username and password set in step 1.
</div>

You will know this command executed correctly when you see `{"ok":true}` in the output.


#### 4. Point Obsidian to the LiveSync Server

Download Obsidian and install it to another device. Once finished with the installation, click the settings gear icon on the bottom. Under Options, go to Community Plugins and click the purple "Browse" button on the right.

Search for `Self-hosted LiveSync`. Click on it, and click the purple "Install" button, and then the purple "Enable" button.

You will be walked through the wizard. It's honestly a bit intimidating.

Select "I am setting this up for the first time" (unless, you are already syncing Obsidian some other way) and click the purple button to continue.

Select "Enter the server information manually" and click the purple button to continue.

You can enable End-to-End encryption if you'd like. It only encrypts data on the server itself, not during transit (without HTTPS, data will not be encrypted in transit. This is solved by using a Tailscale Tailnet, which encrypts in transit with a tunnel). I did not chose this, as it includes requiring a passphrase for every device syncing to your LiveSync server. I just clicked the purple button to continue.

Select "CouchDB", and click the purple button to continue.

Input the details of your CouchDB container:
- URL: `http://<ip>:5984` (as set in step 1)
- Username: `<username>` (as set in step 1)
- Password: `<password>` (as set in step 1)
- Database Name: You actually create a name for your database here. Choose something like `obsidian_sync_db`.

Click the purple "Test Settings and Continue" button. This will check your configurations. When it finishes, click the purple "Restart and Initialise Server" button.

Click each of the check boxes under "Please Confirm the Following". Click "I understand the risks and will proceed without a backup". Click the purple "I understand, Overwrite Server" button.

You will likely get a "Fetch Remote Configuration Failed" "error". Like the error says, this is expected. Just click Skip and proceed.

Click No to sending all chuncks. Click ok to All optional features are disabled.

#### 5. Go Through Config Docter

Likely, the Self-hosted LiveSync Config Doctor will pop up. Humor it by clicking the purple "Yes" button.

Click "Fix it" 3 times (maybe be more careful about this if you already have stuff in obsidian).

Again, you have to confirm overwriting the server data. Click each of the check boxes under "Please Confirm the Following". Click "I understand the risks and will proceed without a backup". Click the purple "I understand, Overwrite Server" button.

Click ok to dismiss the notification. Click No to sending all chuncks. Click ok to All optional features are disabled.

Click "No, never warn please", if you have are not worried about running out of storage. If you are, you can select a different option. This server is extremely lightweight, and storage is very minimal.

#### 6. Final Configurations

Access the settings with the settings gear at the bottom. At the bottom of the left menu, under Community Plugins click Self-hosted LiveSync server. 

Go to the Sync icon tab. I enabled "Sync on Save", "Sync on Editor Save", "Sync on File Open" and "Sync on Startup".

<hr>

Test that the sync is working by writing to a file. As you type and when you save, you should see the up arrow increment in the top left.