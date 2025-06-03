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
7. Copy scripts from cloned scripts repo to ~/bin
8. Install Nerd Fonts with `nerdfonts.sh`
9. Link or copy configuration files with `configs.sh`

### Configuration Files
1. configs.sh
	- Create symbolic links from ~/Downloads/configs for apps in ~/.config/ or copy all directories to ~/.config/
	- Symbolic link to home dot files?
	- Copy config for i3 and polybar because of variations in devices and keybindings.
	- Some config directories/files may be copied for special cases.
		- kitty for the HP 850 G3
		- fastfetch for the Gateway E-475M
2. Contents of ~/Downloads/scripts will be copied to ~/bin to prevent complications in the development process except for VMs.
3. Picom is installed, but have no configuration file for it.

### Misc notes
Check for existing i3 configuration
```bash
check_i3(){
	local i3_cfg_d response backup_dir
	i3_cfg_d="$HOME/.config/i3"
	if [[ "$i3_cfg_d" ]]; then
		echo "An exist ~/.config/i3 directory was found."
		read -rp "Backup the existing configuration? (y/n)" response
		if [[ "$response" =~ ^[Yy]$ ]]; then
			backup_dir="$HOME/.config/i3_backup+$(date +%F-%R)"
			mv "$i3_cfg_d" "$backup_dir" || die "Failed to backup current config" 1
			echo "Backup saveed to $backup_dir"
		fi
	fi
}
```
Replace current .bashrc
```bash
replace_bashrc() {
	local response
	read -rp "Replace your .bashrc with mosfanet .bashrc? (y/n) " response
	if [[ "$response" =~ ^[Yy]$ ]]; then
		wget -O ~/.bashrc https://raw.githubusercontent.com/RickRomig/configs/refs/heads/main/.bashrc
		source ~/.bashrc
	fi
}
```
picom: [FT Labs](https://github.com/FTLabs)
