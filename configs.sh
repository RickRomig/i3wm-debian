#!/usr/bin/env bash
##########################################################################
# Script Name  : configs.sh
# Description  : Setup configuration script in i3WM installation
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025 Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail | rick.romig@mymetronet.net
# Created      : 27 Apr 2025
# Last updated : 03 May 2025
# Comments     : Assumes scripts and directories under ~/bin have already been installed.
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
##########################################################################

set -eu

## Global Variables ##

cloned_dir="$HOME/Downloads/configs"
config_dir="$HOME/.config"

## Functions ##

apply_dotfiles() {
	local dot_file dot_files
	dot_files=( .bash_aliases .bashrc .bash_logout .imwheelrc .inputrc .profile .face )
	printf "\e[93mLinking dotfiles ...\e[0m\n"
	for dot_file in "${dot_files[@]}"; do
		printf "Copying %s ...\n" "$dot_file"
		cp -v "$cloned_dir/$dot_file"  "$HOME/$dot_file" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	done
}

apply_configs() {
	local cfg_dir cfg_dirs
	cfg_dirs=( dunst flameshot kitty micro rofi )
	printf "\e[93mLinking/Copying configuration directories and files ...\e[0m\n"
	for cfg_dir in "${cfg_dirs[@]}"; do
		printf  "Linking %s ...\n" "$cfg_dir"
		ln -s "$cloned_dir/$cfg_dir" "$config_dir/"
	done
	ln -s "$cloned_dir/redshift.conf/" "$config_dir/redshift.conf"
  cp -rv "$cloned_dir/i3" "$config_dir/"
  cp -rv "$cloned_dir/polybar" "$config_dir/"
	cp -v "$HOME/i3wm-debian/dmconf.sh" "$HOME/.local/bin/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	cp -v "$cloned_dir/local/leave.txt" "$HOME/.local/share/doc/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	sudo cp -v "$cloned_dir"/sleep.conf /etc/systemd/
	configure_nano
}

configure_nano() {
	printf "\e[93mConfiguring nano...\e[0m\n"
	cp -v /etc/nanorc "$config_dir/nano/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	sed -i -f nano.sed "$config_dir/nano/nanorc"
}

copy_backgrounds() {
	printf "\e[93mCopying backgrounds...\e[0m\n"
	cp -v "$cloned_dir/backgrounds/*" "$config_dir/backgrounds/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
}

add_sudo_tweaks() {
	printf "\e[93mApplying sudo tweaks...\e[0m\n"
	sudo sh -c 'echo "Defaults pwfeedback" > /etc/sudoers.d/0pwfeedback'
	sudo chmod 440 /etc/sudoers.d/0pwfeedback
	sudo sh -c 'echo "Defaults timestamp_timeout=30" > /etc/sudoers.d/rick'
	sudo chmod 440 /etc/sudoers.d/rick
}

main() {
  local script version
	script="$(basename "$0")"
	version="1.0.25123"
	apply_dotfiles
	apply_configs
	configure_nano
	copy_backgrounds
	add_sudo_tweaks
	printf "\e[93mi3 Window Manager installation complete!\n Reboot your system.\e[0m\n"
	echo "$script $version"
  exit
}

## Execution ##

main "$@"
