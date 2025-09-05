# i3 on Debian Stable
## Description
This repository contains scripts and support files to install the i3 Window Manager on a minimal installation of Debian Stable.
## License
Copyright © 2025, Richard B. Romig
Files and scripts in this reposoitory are licensed under the GNU General Public Licencse, version 2 which can be found in the [repository](https://github.com/RickRomig/i3wm-debian/blob/main/README.md)
## Files
1. **Debian-Minimal-Install.md** - Instructions for a minimal installation of Debian.
2. **install.sh** - Installs i3-wm and necessary software.
3. **configs.sh** - Copies and sets up symbolic links to configuration files.
4. **nerdfonts.sh** - Installs NerdFonts.
5. **utils.sh** - Utility functions to install packages. Sourced by `install.sh`
6. **packages.conf** - Arrays of packages to be installed. Sourced by `install.sh`
7. **i3.desktop** - used by LightDM to launch i3-wm.
8. **slick-greeter** - used by LightDM to login user.
9. **slickback.png** - background for LightDM login screen.
10. **nano.sed** - sed script to configure nanorc.
## Debian Installation
1. Install a minimal installation of Debian stable using **Debian-Minimal-Install.md** as a guide.
	- **Do not** set a root password. Set yourself up as primary user. This will automatically give you sudo access.
	- **Do not** create a swap partition. The `install.sh` script will install ZRam for swap unless it detects swap is already present.
	- Highly recommend setting up a separate home partition. It makes life easier.
2. In the software selection page:
	- Uncheck all desktop environments.
	- Check SSH server. SSH is used to administer all Linux systems on MosfaNet. (Shouldn't be needed in a VM.)
	- Check Standard system utilities.
3. Reboot
## i3 Installation
Once system has rebooted, run the following:
```bash
$ sudo apt install git network-manager	# if not installed during Debian installation
$ git clone https://github.com/RickRomig/i3wm-debian.git ~/i3wm-debian
$ cd i3wm-debian
$ ./install.sh
$ ./nerdfonts.sh
$ ./configs.sh
$ micro .config/polybar/config.ini	# Edit wlan, eth, and battery modules as needed.
$ sudo reboot
```
## NOTES
- The `install.sh` script clones the configs and scripts repositories to ~/Downloads.
- The `install.sh` script copies the contents of the script repository from ~/Downloads/scripts to ~/bin.
- The `configs.sh` script copies or links configuration files from ~/Downloads/configs to ~/.config.
- Configure Polybar modules for network and battery, as applicable, before rebooting after i3 installation.
## Set screen resolution in Gnome-Boxes VM
Add `display-setup-script=xrandr -s 1920x1080` in the `[Seat:*]` section as shown below:
```bash
$ sudo micro /etc/lightdm/lightdm.conf
[Seat:*]
display-setup-script=xrandr -s 1920x1080
#type=xlocal
#pam-service=lightdm
#pam-autologin-service=lightdm-autologin
```
## Terms and conditions
These programs are free software; you can redistribute them and/or modify them under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

These programs are distributed in the hope that they will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

#### Rick Romig "*The Luddite Geek*"
#### 05 September 2025
