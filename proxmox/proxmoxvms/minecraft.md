---
title: Minecraft
layout: default
---

<img src="/jpprojects/images/images/proxmox.png" class="float_img" alt="Proxmox">
<img src="/jpprojects/images/images/minecraft.png" class="float_img" alt="Minecraft">

## Minecraft Server

A mineraft server lets multiple people share a world together without needing to be on the same LAN. Additionally, it can stay on constantly, so anyone can join at any time.

<div class="info">
Some caveats on how I created my server: 1. I took the world data of an existing world I played and put it into the server. This isn't necessary, but creating a new 2. This world was created with Fabric, a lightweight and high-performance mod loader. This let's users use Sodium, a client-side performance optimization mod, and for the server to use Lithium, a server-side performance optimization mod. 
</div>

#### 1. Create the container

In the Proxmox Server/Node, go to the server storage in the left menu (probably called "local"). Click on CT Templates on the inner left menu and then Templates at the top. Find the `ubuntu-24.04-standard` template and click Download.

When it finishes, click the Blue Create CT button in the top right.

- General
    - CT ID : Set an ID
    - Hostname : Set a hostname
    - Password : Set a password
- Template
    - Template : Select the ubuntu template downloaded previously
- Disks
    - Disk Size : 32 GB is probably fine
- CPU
    - Cores : At least 2, 3 would be better
- Memory
    - Memory : 13351 Mib
- Network
    - IPv4 : set an IP address in CIDR notation (i.e. 192.168.1.100/24)
    - Gateway : Set a gateway (no CIDR notation needed)
- DNS
    - DNS Domain & DNS Server : Leave blank to use host DNS, or specificy a DNS Server

On the confirm tab, check that everything is correct and then click Finish at the bottom. Let the container build.

#### 2. Install dependencies

After the container appears under the Proxmox Server/Node, start it (click it, right click, start). Once it has started, go to console and login as `root` with the password set in step 1.

Make sure everything is up to date with `apt update && apt upgrade -y`. Then install some base dependencies with `apt install -y screen ufw curl`.

Install Java 25:
- `curl -s https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto.gpg`
- `echo "deb [signed-by=/usr/share/keyrings/corretto.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list`
- `apt update && apt install -y java-25-amazon-corretto-jdk`

Verify it worked with `java -version`. It should show Java 25 as installed.

#### 3. Set up the Firewall

UFW is easy. Port 25565 is the default Minecraft port:
- `ufw allow 22`
- `ufw allow 25565`
- `ufw enable`

#### 4. Install Fabric and Minecraft

Create a Minecraft Directory
- `mkdir -p /opt/minecraft && cd /opt/minecraft`

Download latest Fabric installer
- `wget https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar`

Install for Minecraft 26.1 (or whatever version you want).
- `java -jar fabric-installer-1.0.1.jar server -mcversion 26.1 -loader 0.18.4 -downloadMinecraft`

#### 5. Accept the EULA
Run `echo "eula=true" > /opt/minecraft/eula.txt`

#### 6. Bring in Existing World Data

This can be done in several ways. You just need to move the world data from wherever it is into the Minecraft directory.

I used SCP to move my world folder from my Windows machine to the container itself. First, SSH configs need to be fixed to allow SCP to run as root. Go to `nano /etc/ssh/sshd_config`, and add these lines to the bottom of the file:

```
PermitRootLogin yes
PasswordAuthentication yes
```

Exit with Ctrl+O and Ctrl+X. Restart SSH: `systemctl restart ssh`.

Then I ran this command from Powershell on my PC: `scp -r "$env:APPDATA\.minecraft\saves\<worldname>" root@<container-ip>:/opt/minecraft/`

Then I moved it into the right spot: `mv /opt/minecraft/YourWorldName /opt/minecraft/world`.

#### 7. Edit Server Properties

The settings of the server will cap certain properties, and players settings won't be able to go past those settings.

Those settings are found in `nano /opt/minecraft/server.properties`. 

Keep an eye out for

```
view-distance=24
simulation-distance=16
```

#### 8. Create a Start Script (Optional)

Create the script itself:
- `nano /opt/minecraft/start.sh`

Copy and paste this in there: 

```
cd /opt/minecraft
java -Xms2G -Xmx6G -jar fabric-server-launch.jar nogui
```

Set the right permissions with `chmod +x /opt/minecraft/start.sh`. Then `./start.sh` can start and stop the server.

#### 9. Start the Server

The server is started with `screen -S minecraft` or `/opt/minecraft/start.sh`. "Detatch" with Ctrl+A and then Ctrl+D to see the server booting up. It should finish booting with a few seconds.

The server can also be started directly (without screen): `java -Xms1G -Xmx3G -jar fabric-server-launch.jar nogui`.

If an old screen session is stuck, it can be killed before starting again: `screen -S minecraft -X quit`. 

Live console output can be seen anytime: `journalctl -u minecraft -f`.

<hr>

#### 10. Enable a Service

<div class="info">
Before you do this, be sure there is not an instance of the server running already, otherwise there will be some funky errors.
</div>

To not have to worry about keeping the server up manually, a service can be set to start the server on boot. That way, if something goes wrong, the container can just be restarted and the server will boot.

First, create a service file: `nano /etc/systemd/system/minecraft.service`

Paste this in there:

```
[Unit]
Description=Minecraft Fabric Server
After=network.target

[Service]
User=root
WorkingDirectory=/opt/minecraft
ExecStart=/usr/bin/java --enable-native-access=ALL-UNNAMED -Xms2G -Xmx6G -jar fabric-server-launch.jar nogui
Restart=on-failure
RestartSec=10
StandardInput=null

[Install]
WantedBy=multi-user.target
```

Save and finish with Ctrl+O and Ctrl+x

- Reload systemd so it sees the new service
    - `systemctl daemon-reload`

- Enable it so it starts on boot
    - `systemctl enable minecraft`

- Start it now
    - `systemctl start minecraft`

Check that it is running with `systemctl status minecraft`. You should see `active (running)` in green.

#### 11. Install Lithium

Lithium improves game logic for servers, which will increase the performcance and stability.

First, check that a mods folder exists: `ls /opt/minecraft/`.
If it doesn't, create it: `mkdir /opt/minecraft/mods`.

Then, find the correct Lithium version on [Modrinth](https://modrinth.com/mod/lithium?version=26.1&loader=fabric), and get the donwload link that matches your Minecraft and Fabric versions. If something breaks when restarting, make sure you got the right version.

Download it to the server:

```
cd /opt/minecraft/mods
wget -O lithium.jar "<Lithium Download Link>"
```

Then restart the server (`systemctl restart minecraft`) and check that it is working (`journalctl -u minecraft -f`). You should see a line mentioning Lithium.

I recommend enabling Start on Boot for the container itself in Proxmox. This is found by clicking the container in the left menu, going to options, clicking Start at boot, clicking Edit at the top, and enabling.

<hr>

#### 12. Updating the Minecraft Server

Minecraft has a new update (drop) about every 3 months. So, knowing the workflow for updating the minecraft server is important.

<div class="info">
The server described here uses multiple different programs (Fabric, Lithium, Sodium) which all need to match the game version you are playing. In can take a few days after the latest game drop for the developers of these projects to have the latest compatible version ready. Confirm these versions exist and are ready before doing this update process so you don't get stuck halfway through and aren't able to run the server.
</div>

First, take a snapshot, so that in case something goes wrong you can roll back and not lose your world! With the container selected in the left menu, click on Snapshots, then Take Snapshot at the top. If you are particularly paranoid, especially if you dont have a full backup already, consider making a clone of the entire VM instead by right clicking the container in the left menu and selecting Clone (the container needs to be off first).

Then, in the terminal, stop the Minecraft service: `systemctl stop minecraft`.

Next, confirm you have the right version of Java. Run `java -version` to confirm what version of Java you are running. You can Google the required version for the latest Minecraft version to ensure compatibility.

Then, while in the proper folder, (`cd /opt/minecraft`) run `java -jar fabric-installer-1.0.1.jar server -mcversion X.Y -downloadMinecraft`. Replace "X.Y" with the latest minecraft version. This pulls all the latest versions and updates `libraries/` and `versions/` properly.

Next, create a new folder and move the current (old) mods to make room for the new (latest) versions: `mkdir mods-old && mv mods/*.jar mods-old/`. Enter the mods folder `cd /opt/minecraft/mods`. Run `apt install -y jq` to install jq, a dependecy for this next install command.

This command will pull the latest version of the Fabric API jar and Lithium jar.

```
for mod in fabric-api lithium; do
  url=$(curl -sG "https://api.modrinth.com/v2/project/$mod/version" \
    -A "minecraft-server-update" \
    --data-urlencode 'loaders=["fabric"]' \
    --data-urlencode 'game_versions=["26.3"]' \
    | jq -r '.[0].files[] | select(.primary) | .url')
  echo "$mod -> $url"
  curl -fLO "$url"
done
ls -l
```

Finally, start the server daemon back up: `systemctl start minecraft`

Give it a minute to start, and then check the logs to make sure the server started correctly.

<hr>

#### 13. Updating your Minecraft Client

This is how to update your game on both Windows and Mac.

**Windows**


**Mac**

First, in Terminal, run `rm -rf ~/Library/Application\ Support/minecraft/launcher/launcher.bundle`. This removes this launcher.bundle file which is known (at this time) to have issues on Mac when updating Minecraft. By removing it, the game has to recreate the file and is able to update without issue.

Then, download the latest Fabric version (here)[https://fabricmc.net/use/installer/]. Install the app, then use it and download the latest version.

Then you need to download the latest version of Sodium (here)[https://modrinth.com/mod/sodium]. Click the download button and use the Install Manually section (be sure to select Fabric as the platform).

Next you need to move the Sodium download to the right folder. In a Finder window, do Command + Shift + G and search for this file path: `~/Library/Application Support/minecraft/mods`. Delete the current (old) Sodium file in there and drag and drop the new (latest) Sodium file into this file.

Finally, launch the game. It should download the update automatically, and you can select the latest Fabric version in the version control menu on the left.