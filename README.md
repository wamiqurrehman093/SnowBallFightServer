# Snow Ball Fight - Server
### Godot server project for the <a href="#" target="_blank">Snow Ball Fight</a> game.

## Setup

1. Clone the repository.
2. Download the <a href="#" target="_blank">Godot Engine 4.3</a> if you haven't already.
3. Run a new instance of the Godot Engine.
4. Import and run the cloned project in the Godot Project Manager.
5. Run the server with the Play button.

## Deploying Custom Server

1. Install the Export Templates from the Editor menu if you haven't already by going to Editor/Manage Export Templates... then clicking Install.
2. Export the project as .pck file from the Linux Export Preset with the name of your choice eg. snow_ball_fight_server.pck.
3. Open exports template folder by going to Editor/Manage Export Templates then clicking Open Folder.
4. Copy the export template file which represents the platform and architecture of your export, assuming the exported pck file was for Linux platform with .x86_64 architecture with debug option on so select **linux_debug.x86_64** file.
5. Copy and paste the file to the folder of exported pck file.
6. Rename the **linux_debug.x86_64** file to match the name of the pck file excluding the file extension, something like this **snow_ball_fight_server.x86_64**
7. Setup your Linux server either by yourself on a local machine with static IP address or by purchasing a suitable plan from a VPS provider such as <a href="https://www.linode.com/" target="_blank">Linode</a>.
8. After your Linux server is ready, take a note of your IP address using `ip addr` command if you have set it up on a local machine or by using your VPS provider's dashboard if you have set it up using a VPS provider such as Linode.
9. Copy those two selected files and paste them to your server, you can use <a href="https://filezilla-project.org/" target="_blank">FileZilla</a> to transfer files to your server.
10. SSH into your server, you can use <a href="https://www.putty.org/" target="_blank">PuTTY</a> to do that.
11. Update permissions on the **snow_ball_fight_server.x86_64** to make it executable using `chmod +x snow_ball_fight_server.x86_64` command.
12. Run the **snow_ball_fight_server.x86_64** file with `./snow_ball_fight_server.x86_64 --headless`
13. You can then create a systemd service for the server to keep it running, <a href="https://medium.com/@benmorel/creating-a-linux-service-with-systemd-611b5c8b91d6" target="_blank">read more here</a>.
14. Follow **Deploying Custom Server** section from <a href="https://github.com/wamiqurrehman093/SnowBallFight?tab=readme-ov-file#deploying-custom-server" target="_blank">SnowBallFight</a> repository.