#!/usr/bin/env bash
###############################################################################
# Script Name  : copy-conf.sh
# Description  : Copy configuration files from the configs repo to proper locations.
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Last updated : 10 Apr 2025
# Comments     :
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
###############################################################################

# This script is used to copy config files over for use on reboot after installation.
# Original script by Drew Griff, with many modifications and enhancements by Rick Romig
# Assumes scripts and directories under ~/bin have already been installed.

## Global Variables ##

cloned_dir="$HOME/Downloads/configs"
config_dir="$HOME/.config"

## Functions ##

copy_dotfiles() {
	local dot_file dot_files
	dot_files=( .bash_aliases .bashrc .bash_logout .imwheelrc .inputrc .profile .face )
	printf "Copying .dotfiles ...\n"
	for dot_file in "${dot_files[@]}"; do
		printf "Copying %s ...\n" "$dot_file"
		cp -v "$cloned_dir/$dot_file"  "$HOME/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	done
}

copy_configs() {
	local cfg_dir cfg_dirs
	cfg_dirs=( dunst i3 kitty micro polybar rofi )
	printf "Copying configuration directories and files ...\n"
	for cfg_dir in "${cfg_dirs[@]}"; do
		printf  "Copying %s ...\n" "$cfg_dir"
		cp -rv "$cloned_dir/$cfg_dir" "$config_dir/"
	done
	cp -v "$cloned_dir/redshift.conf/" "$config_dir/"
	sudo cp -v "$cloned_dir"/sleep.conf /etc/systemd/
	configure_nano
	config_executables
}

config_executables() {
	local bin_dir="$HOME/.local/bin"
	local src_dir="$HOME/i3wm-debian/.local/bin"
	cp -v "$src_dir/dmconf.sh" "$bin_dir/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	[[ -x "$bin_dir/dmconf.sh" ]] || chmod +x "$bin_dir/dmconf.sh"
	[[ -x "$config_dir/i3/autostart.sh" ]] || chmod +x "$config_dir/i3/autostart.sh"
	[[ -x "$config_dir/i3/logout" ]] || chmod +x "$config_dir/i3/logout"
	[[ -x "$config_dir/polybar/polybar-i3" ]] || chmod +x "$config_dir/polybar/polybar-i3"
}

configure_nano() {
	printf "Configuring nano...\n"
	[[ -d "$config_dir/nano" ]] || mkdir -p "$config_dir/nano"
	cp -v /etc/nanorc "$config_dir/nano/"
	sed -i -f "$HOME/bin/files/nano.sed" "$config_dir/nano/nanorc"
	[[ -f "$HOME/.nanorc" ]] && rm "$HOME/.nanorc"
}

copy_backgrounds() {
	printf "Copying backgrounds...\n"
	[[ -d "$config_dir/backgrounds" ]] || mkdir -p "$config_dir/backgrounds"
	cp -v "$cloned_dir/backgrounds/*" "$config_dir/backgrounds/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
}

add_sudo_tweaks() {
	sudo sh -c 'echo "Defaults pwfeedback" > /etc/sudoers.d/0pwfeedback'
	sudo chmod 440 /etc/sudoers.d/0pwfeedback
	sudo sh -c 'echo "Defaults timestamp_timeout=30" > /etc/sudoers.d/rick'
	sudo chmod 440 /etc/sudoers.d/rick
}

main() {
	local script version
	script="$(basename "$0")"
	version="1.0.25100"
	copy_dotfiles
	copy_configs
	copy_backgrounds
	add_sudo_tweaks
	echo "$script $version"
}

## Execution ##

main "$@"
