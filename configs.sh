#!/usr/bin/env bash
##########################################################################
# Script Name  : configs.sh
# Description  : Setup configuration script in i3WM installation
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025 Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail | rick.romig@mymetronet.net
# Created      : 27 Apr 2025
# Last updated : 31 Oct 2025
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
		printf "\e[93mLinking %s ...\e[0m\n" "$dot_file"
		[[ -f "$HOME/$dot_file" ]] && mv -v "$HOME/$dot_file" "$HOME/old-configs/"
		ln -sv ~/Downloads/configs/"$dot_file" ~/"$dot_file"
	done
}

# Link specific configuration files to directories in ~/.config
link_configs() {
	local file files
	files=(
		"dunst/dunstrc"
		"flameshot/flameshot.ini"
		"glow/glow.yml"
		"micro/bindings.json"
		"micro/settings.json"
		"picom/picom.conf"
		"rofi/arc_dark_colors.rasi"
		"rofi/arc_dark_transparent_colors.rasi"
		"rofi/config.rasi"
		"redshift.conf"
	)
	for file in "${files[@]}"; do
		if [[ -f "$HOME/Downloads/configs/$file" ]]; then
			printf "\e[93mLinking %s to %s ...\e[0m\n" "$HOME/Downloads/configs/$file" "$HOME/.config"
			if [[ "$file" == "redshift.conf" ]]; then
				mv -v "$HOME/.config/$file" "$HOME/old-configs/"
			else
				[[ -d "$HOME/old-configs/${file%/*}" ]] || mkdir -p "$HOME/old-configs/${file%/*}"
				mv -v "$HOME/.config/$file" "$HOME/old-configs/${file%/*}/${file##*/}"
			fi
			ln -sv ~/Downloads/configs/"$file" ~/.config/"$file"
		fi
	done
  micro -plugin install bookmark
}

# Copy configuration directories to ~/.config
copy_configs(){
	local cfg_dir cfg_dirs
	cfg_dirs=(
		i3
		kitty
		keepassxc
		polybar
		systemd
	)
	for cfg_dir in "${cfg_dirs[@]}"; do
		printf "\e[93mCopying %s ...\e[0m\n" "$cfg_dir"
		cp -rv "$HOME/Downloads/configs/$cfg_dir" "$HOME/.config"/
	done
}

# Copy miscellaneous files
copy_misc_files() {
	printf "\e[93mCopying miscellaneous files...\e[0m\n"
	cp -rv "$HOME/Downloads/configs"/icons/ "$HOME"/.icons/
	ln -sv ~/Downloads/configs/backgrounds ~/.config/
	ln -sv ~/Downloads/configs/local/leave.txt ~/.local/share/doc/leave.txt
}

# Configure the nano text editor
configure_nano() {
	printf "\e[93mConfiguring nano...\e[0m\n"
	cp -v /etc/nanorc "$HOME/Downloads/configs"/nano/
	sed -i -f nano.sed "$HOME/Downloads/configs"/nano/nanorc
}

# Set reserved space for root and home partitions
set_reserved_space() {
	local home_part root_part data_part rbc blk_cnt res_pct
	root_part=$(df -P | awk '$NF == "/" {print $1}')
	home_part=$(df -P | awk '$NF == "/home" {print $1}')
	data_part=$(df -P | awk '$NF == "/data" {print $1}')
	rbc=$(sudo /usr/sbin/tune2fs -l "$root_part" | awk '/Reserved block count/ {print $NF}')
	blk_cnt=$(sudo /usr/sbin/tune2fs -l "$root_part" | awk '/Block count/ {print $NF}')
	res_pct="$(bc <<< "${rbc} * 100 / ${blk_cnt}")"
	printf "e[93mSetting reserved space on root & home partitions...\e[0m\n"
	[[ "$res_pct" -ne 5 ]] && sudo /usr/sbin/tune2fs -m 2 "$root_part"
	[[ "$home_part" ]] && sudo /usr/sbin/tune2fs -m 0 "$home_part"
	[[ "$data_part" ]] && sudo /usr/sbin/tune2fs -m 0 "$data_part"
	printf "Drive reserve space set.\n"
}

# Add tweaks to /etc/sudoers.d directory and set swappiness
apply_system_tweaks() {
	local repo_dir=~/Downloads/configs
	printf "\e[93mApplying password feedback...\e[0m\n"
	sudo cp -v "$repo_dir"/sudoers/0pwfeedback /etc/sudoers.d/
	sudo chmod 440 /etc/sudoers.d/0pwfeedback
	printf "\e[93mApplying sudo timeout...\e[0m\n"
	sudo cp -v "$repo_dir"/sudoers/10timeout /etc/sudoers.d/
	sudo chmod 440 /etc/sudoers.d/10timeout
	printf "\e[93mApplying settings for sleep/suspend...\e[0m\n"
	sudo cp -v "$repo_dir"/sleep.conf /etc/systemd/
	printf "\e[93mDisabling snaps...\e[0m\n"
	sudo cp -v "$repo_dir"/apt/nosnap.pref /etc/apt/preferences.d/
	printf "\e[93mSetting swappiness...\e[0m\n"
	sudo cp -v "$repo_dir"/90-swappiness.conf /etc/sysctl.d/
	printf "\e[93mSetting sleep.conf...\e[0m\n"
	sudo cp -v "$repo_dir"/99-sleep.conf /etc/systemd/sleep.conf.d/
	set_reserved_space
}

show_polybar_devices() {
	local eth_int wifi_int bat_name
	eth_int=$(find /sys/class/net -name "e*")
	wifi_int=$(find /sys/class/net -name "w*")
	bat_name=$(find /sys/class/power_supply/ -name "BAT*")
	printf "\e[93mPolybar device names:\e[0m\n"
	[[ "$eth_int" ]] && printf "Ethernet: %s\n" "${eth_int##*/}"
	[[ "$wifi_int" ]] && printf "Wireless: %s\n" "${wifi_int##*/}"
	[[ "$bat_name" ]] && printf "Battery:  %s\n" "${bat_name##*/}"
}

main() {
	local script="${0##*/}"
	local version="2.3.25304"
	[[ -d ~/old-configs ]] || mkdir -p ~/old-configs
	link_dotfiles
	link_configs
	copy_configs
	copy_misc_files
	configure_nano
	apply_system_tweaks
	printf "\e[93mi3 Window Manager installation complete!\e[0m\n"
	printf "Remember to configure Polybar before rebooting.\n"
	show_polybar_devices
	echo "$script $version"
	exit
}

## Execution ##

main "$@"
