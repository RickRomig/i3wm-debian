# i3 on Debian Stable
## Files
1. **Debian-Minimal-Install.md** - Instructions for a minimal installation of Debian.
2. **run.sh** - Installs i3-wm and necessary software.
3. **configs.sh** - Copies and sets up symbolic links to configuration files.
4. **nerdfonts.sh** - Installs NerdFonts.
5. **utils.sh** - Utility functions to install packages.
6. **dmconf.sh** - Dmenu script to edit config files.
7. **packages.conf** - Arrays of packages to be installed.
8. **i3.desktop** - used by LightDM to launch i3-wm.
9. **slick-greeter** - used by LightDM to login user.
10. **solarized-debian.png** - background for login screen.
11. **nano.sed** - sed script to configure nanorc.
## Debian Installation
1. Install a minimal installation of Debian stable using **Debian-Minimal-Install.md** as a guide.
	- **Do not** set a root password. Set yourself up as primary user. This will automatically give you sudo access.
	- **Do not** create a swap partition. The `run.sh` script will install ZRam for swap unless it detects swap is already present.
	- Highly recommend setting up a separate home partition. It makes life easier.
2. In the software selection page:
	- Uncheck all desktop environments.
	- Check SSH server. SSH is used to administer all Linux systems on MosfaNet.
	- Check Standard system utilities.
3. Reboot
## i3 Installation
Once system has rebooted, run the following:
```bash
sudo apt install git
git clone https://github.com/RickRomig/i3wm-debian.git ~/i3wm-debian
cd i3wm-debian
./run.sh
./nerdfonts.sh
./configs.sh
sudo reboot
```
## NOTES
- The `run.sh` script will clone the configs and scripts repositories to ~/Downloads.
- The `run.sh` script will copy the contents of the script repository from ~/Downloads/scripts to ~/bin.
- Recommend configuring Polybar modules for network and battery, as applicable.
## Set screen resolutino in Gnome-Boxes VM
```bash
sudo micro /etc/lightdm/lightdm.conf
[Seat:*]
display-setup-script=xrandr -s 1920x1080
#type=xlocal
#pam-service=lightdm
#pam-autologin-service=lightdm-autologin
```

#### Rick Romig "*The Luddite Geek*"
#### 02 May 2025
