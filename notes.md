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
3. Install packages with functions in `utils.sh` (Flatpak and Flathub are installed)
	- Install disk utilities as applicable
4. Setup LightDM
5. Enable services
6. Copy scripts from cloned scripts repo to ~/bin
7. Install Nerd Fonts with `nerdfonts.sh` script
8. Copy configuration files with `configs.sh` script

### Configuration Files
1. run.sh
	- Copies scripts and supporting filesl from ~/Downloads/scripts to ~/bin
2. configs.sh
	- Copies all directories and reshift.conf from ~/Downloads/configs to ~/.config/
3. Picom is installed, but I have no configuration file for it.
	- i3/autostart.sh runs `piccom -b`

### Misc notes
Check for existing i3 configuration (not implemented)
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
Replace current .bashrc (not implemented)
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
