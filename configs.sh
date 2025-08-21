#!/usr/bin/env bash
##########################################################################
# Script Name  : configs.sh
# Description  : Setup configuration script in i3WM installation
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025 Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail | rick.romig@mymetronet.net
# Created      : 27 Apr 2025
# Last updated : 20 Aug 2025
# Comments     :
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

## Global Variables ##

readonly cloned_dir="$HOME/Downloads/configs"
readonly config_dir="$HOME/.config"
readonly old_configs="$HOME/old-configs"

## Functions ##

# Create symbolic links to dotfiles in the home directory
link_dotfiles() {
	local dot_file dot_files
	dot_files=(
		.bash_aliases
		.bashrc
		.bash_logout
		.face
		.imwheelrc
		.inputrc
		.profile
	)
	printf "\e[93m93mLinking dotfiles ...\e[0m\n"
	for dot_file in "${dot_files[@]}"; do
		# printf "\e[93mLinking %s ...\e[0m\n" "$dot_file"
		# cp -v "$cloned_dir/$dot_file" "$HOME/$dot_file" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
		printf "\e[93mLinking %s ...\e[0m\n" "$dot_file"
		[[ -f "$HOME/$dot_file" ]] && mv -v "$HOME/$dot_file" "$old_configs/"
		ln -sv "$cloned_dir/$dot_file" "$HOME/$dot_file"
	done
}

# Link specific configuration files to directories in ~/.config
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
		if [[ -f "$config_dir/$file" ]]; then
			printf "\e[93mLinking %s to %s ...\e[0m\n" "$cloned_dir/$file" "$config_dir"
			if [[ "$file" == "redshift.conf" ]]; then
				mv -v "$config_dir/$file" "$old_configs/"
			else
				[[ -d "$old_configs/${file%/*}" ]] || mkdir -p "$old_configs/${file%/*}"
				mv -v "$config_dir/$file" "$old_configs/${file%/*}/${file##*/}"
			fi
			ln -sv "$cloned_dir/$file" "$config_dir/$file"
		fi
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
	ln -sv "$cloned_dir/local/leave.txt" "$HOME/.local/share/doc/leave.txt"
}

# Configure the nano text editor
configure_nano() {
	printf "\e[93mConfiguring nano...\e[0m\n"
	cp -v /etc/nanorc "$config_dir/nano/" | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	sed -i -f nano.sed "$config_dir/nano/nanorc"
}

# Add tweaks to /etc/sudoers.d directory and set swappiness
set_system_tweaks() {
	printf "\e[93mApplying password feeback...\e[0m\n"
	sudo cp -v "$cloned_dir/sudoers/0pwfeedback" /etc/sudoers.d/ | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	sudo chmod 440 /etc/sudoers.d/0pwfeedback
	printf "\e[93mApplying sudo timeout...\e[0m\n"
	sudo cp -v "$cloned_dir/sudoers/10timeout" /etc/sudoers.d/ | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
	sudo chmod 440 /etc/sudoers.d/10timeout
	printf "\e[93mApplying swappiness...\e[0m\n"
	echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
	printf "Applying settings for sleep/suspend...\n"
	sudo cp -v "$cloned_dir"/sleep.conf /etc/systemd/ | awk -F"/" '{print "==> " $NF}' | sed "s/'$//"
}

main() {
	local script="${0##*/}"
	local version="1.14.25232"
	[[ -d "$old_configs" ]] || mkdir -p "$old_configs"
	link_dotfiles
	link_configs
	copy_configs
	copy_misc_files
	configure_nano
	set_system_tweaks
	printf "\e[93mi3 Window Manager installation complete!\n Reboot your system.\e[0m\n"
	printf "Remember to edit your Polybar configuration!\n"
	echo "$script $version"
  exit
}

## Execution ##

main "$@"
