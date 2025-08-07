#!/usr/bin/env bash
##########################################################################
# Script Name  : configs.sh
# Description  : Setup configuration script in i3WM installation
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025 Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail | rick.romig@mymetronet.net
# Created      : 27 Apr 2025
# Last updated : 05 Aug 2025
# Comments     : Assumes scripts and directories under ~/bin have already been copied.
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
# License URL  : https://github.com/RickRomig/i3wm-debian/blob/main/LICENSE
###########################################################################
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
##########################################################################

set -eu

## Global Variables ##

readonly cloned_dir="$HOME/Downloads/configs"
readonly config_dir="$HOME/.config"

## Functions ##

# Copy dotfiles to the home directory
copy_dotfiles() {
	local dot_file dot_files
	dot_files=(
		.bash_aliases
		.bashrc
		.bash_logout
		.curlrc
		.face
		.imwheelrc
		.inputrc
		.profile
		.wgetrc
	)
	printf "\e[93mCopying dotfiles ...\e[0m\n"
	for dot_file in "${dot_files[@]}"; do
		# printf "\e[93mCopying %s ...\e[0m\n" "$dot_file"
		# cp -v "$cloned_dir/$dot_file" "$HOME/$dot_file" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
		printf "\e[93mLinking %s ...\e[0m\n" "$dot_file"
		[[ -f "$HOME/$dot_file" ]] && rm "$HOME/$dot_file"
		ln -sv "$cloned_dir/$dot_file" "$HOME/$dot_file"
	done
}

# Link configuration files to directories in ~/.config
link_configs() {
	local file files
	files=(
		"dunst/dunstrc"
		"flameshot/flameshot.ini"
		"kitty/bindings.list"
		"kitty/kitty.conf"
		"micro/bindings.json"
		"micro/settings.json"
		"picom/picom.conf"
		"rofi/arc_dark_colors.rasi"
		"rofi/arc_dark_transparent_colors.rasi"
		"rofi/config.rasi"
		"redshift.conf"
	)
	for file in "${files[@]}"; do
		printf "\e[93mLinking %s to %s ...\e[0m\n" "$cloned_dir/$file" "$config_dir"
		[[ -f "$config_dir/$file" ]] && rm "$config_dir/$file"
		ln -sv "$cloned_dir/$file" "$config_dir/$file"
	done
  micro -plugin install bookmark
}

# Copy configuration directories to ~/.config
copy_configs(){
	local cfg_dir cfg_dirs
	cfg_dirs=(
		backgrounds
		i3
		keepassxc
		polybar
		systemd
	)
	for cfg_dir in "${cfg_dirs[@]}"; do
		printf "\e[93mCopying %s ...\e[0m\n" "$cfg_dir"
		cp -rv "$cloned_dir/$cfg_dir" "$config_dir/"
	done
}

# Copy miscellaneous files
copy_misc_files() {
	printf "\e[93mCopying miscellaneous files...\e[0m\n"
	cp -v "$cloned_dir/icons/*" "$HOME/.icons/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	cp -v "$HOME/i3wm-debian/dmconf.sh" "$HOME/.local/bin/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	cp -v "$cloned_dir/local/leave.txt" "$HOME/.local/share/doc/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	sudo cp -v "$cloned_dir"/sleep.conf /etc/systemd/ | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
}

# Configure the nano text editor
configure_nano() {
	printf "\e[93mConfiguring nano...\e[0m\n"
	cp -v /etc/nanorc "$config_dir/nano/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	sed -i -f nano.sed "$config_dir/nano/nanorc"
}

# Add tweaks to /etc/sudoers.d directory
add_sudo_tweaks() {
	printf "\e[93mApplying sudo tweaks...\e[0m\n"
	sudo cp -v "$cloned_dir/sudoers/0pwfeedback" /etc/sudoers.d/ | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	sudo chmod 440 /etc/sudoers.d/0pwfeedback
	sudo cp -v "$cloned_dir/sudoers/10timeout" /etc/sudoers.d/ | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	sudo chmod 440 /etc/sudoers.d/10timeout
}

main() {
	local script="${0##*/}"
	local version="1.10.25216"
	copy_dotfiles
	link_configs
	copy_configs
	copy_misc_files
	configure_nano
	add_sudo_tweaks
	echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
	printf "\e[93mi3 Window Manager installation complete!\n Reboot your system.\e[0m\n"
	printf "Remember to edit your Polybar configuration!\n"
	echo "$script $version"
  exit
}

## Execution ##

main "$@"
