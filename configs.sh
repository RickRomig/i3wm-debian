#!/usr/bin/env bash
##########################################################################
# Script Name  : configs.sh
# Description  : Setup configuration script in i3WM installation
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025 Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail | rick.romig@mymetronet.net
# Created      : 27 Apr 2025
# Last updated : 28 Apr 2025
# Comments     : Assumes scripts and directories under ~/bin have already been installed.
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
##########################################################################

set -eu

## Global Variables ##

script=$(basename "$0"); readonly script
readonly version="1.1.25118"
cloned_dir="$HOME/Downloads/configs"
config_dir="$HOME/.config"

## Functions ##

apply_dotfiles() {
	local dot_file dot_files
	dot_files=( .bash_aliases .bashrc .bash_logout .imwheelrc .inputrc .profile .face )
	printf "Linking dotfiles ...\n"
	for dot_file in "${dot_files[@]}"; do
		printf "Linking %s ...\n" "$dot_file"
		ln -s "$cloned_dir/$dot_file"  "$HOME/$dot_file"
	done
}

apply_configs() {
	local cfg_dir cfg_dirs
	cfg_dirs=( dunst kitty micro rofi )
	printf "Copying configuration directories and files ...\n"
	for cfg_dir in "${cfg_dirs[@]}"; do
		printf  "Linking %s ...\n" "$cfg_dir"
		ln -s "$cloned_dir/$cfg_dir" "$config_dir/"
	done
	ln -s "$cloned_dir/redshift.conf/" "$config_dir/redshift.conf"
  cp -rv "$cloned_dir/i3" "$config_dir/"
  cp -rv "$cloned_dir/polybar" "$config_dir/"
	cp -v "$HOME/i3wm-debian/dmconf.sh" "$HOME/.local/bin/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	sudo cp -v "$cloned_dir"/sleep.conf /etc/systemd/
	configure_nano
}

configure_nano() {
	printf "Configuring nano...\n"
	[[ -d "$config_dir/nano" ]] || mkdir -p "$config_dir/nano"
	cp -v /etc/nanorc "$config_dir/nano/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
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
	version="1.1.25118"
	apply_dotfiles
	apply_configs
	configure_nano
	copy_backgrounds
	add_sudo_tweaks
	echo "$script $version"
  exit
}

## Execution ##

main "$@"
