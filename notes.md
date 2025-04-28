# NOTES
## i3wm-debian installation scripts

### Initial Setup
1. Function to check if installation is a virtual machine
	- If a VM, install `spice-vdagent` and `spice-webdavd`
2. Install essential tools and packages
	- Install `zram-tools`
	- Install microcode
	- Install Bluetooth (if present)
	- Set up XDG and user directories
	- Clone configs and scripts repositories to ~/Downloads
3. Install packages with functions in `utils.sh`
	- Install disk utilities as applicable
4. Setup LightDM
5. Install Flatpak
6. Enable services
7. Copy scripts from cloned repo ~/bin with functions in `utils.sh`
8. Install Nerd Fonts with `nerdfonts.sh`
9. Link or copy configuration files with `configs.sh`

### Configuration Files
1. Replace copyconf.sh with configs.sh
	- Create symbolic links from ~/Downloads/configs for apps in ~/.config/
	- Symbolic link to home dot files?
	- Copy config for i3 and polybar because of variations in devices and keybindings.
	- Some config directories/files may be copied for special cases.
		- kitty for the HP 850 G3
		- fastfetch for the Gateway E-475M
2. Contents of ~/Downloads/scripts will be copied to ~/bin to prevent complications in the development process.
3. Picom is installed, but have no configuration file for it.
