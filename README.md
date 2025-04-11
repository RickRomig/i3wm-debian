# i3 on Debian Stable

### Files
1. **Debian-Minimal-Install.md** - Instructions for a minimal installation of Debian.
2. **run.sh** - Installs i3-wm and necessary software.
3. **copy-conf.sh** - Installs configuration files.
4. **nerdfonts.sh** - Installs NerdFonts.
5. **utils.sh** - Utility functions to install packages.
6. **dmconf.sh** - Dmenu script to edit config files.
7. **packages.conf** - Arrays of packages to be installed.
8. **i3.desktop** - used by LightDM to launch i3-wm.
9. **slick-greeter** - used by LightDM to login user.
10. **solarized-debian.png** - background for login screen.

### Debian Installation
1. Install a minimal installation of Debian stable using **Debian-Minimal-Install.md** as a guide.
	- **Do not** set a root password. Set yourself up as primary user. This will automatically give you sudo access.
	- **Do not** create a swap partition. The `run.sh` script will install ZRam for swap.
	- Highly recommend setting up a separate home partition. It makes life easier.
2. In the software selection page:
	- Uncheck all desktop environments.
	- Check SSH server. SSH is used to administer all Linux systems on MosfaNet.
	- Check Standard system utilities.
3. Reboot
4. Once system has rebooted, run the following:
```bash
sudo apt install git
git clone http://192.168.0.16:3000/Nullifidian/i3wm-debian.git ~/i3wm-debian
cd i3wm-debian
./run.sh 	# includes nerdfonts.sh and copy-conf.sh
sudo reboot
```

#### NOTES
- Drew Grif's videos:
	- [Debian Stable Minimal Install](https://www.youtube.com/watch?v=Seqx3Oj5JRE)
	- [How to use this github.com](https://www.youtube.com/watch?v=npc4-jp_wvs)
- The `run.sh` script will clone my script repository to ~/Downloads and copy the contents to ~/bin.

#### Rick Romig "*The Luddite Geek*"
#### 10 April 2025
