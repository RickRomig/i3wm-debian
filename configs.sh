#!/usr/bin/env bash
##########################################################################
# Script Name  : configs.sh
# Description  : copy & link configuration files for new i3WM installation
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025 Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail | rick.romig@mymetronet.net
# Created      : 27 Apr 2025
# Updated      : 02 Nov 2026
# Version      : 3.3.26306
# Comments     : Run after nerfonts.sh
#              : Configures polybar and completes i3 installation.
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
# License URL  : https://github.com/RickRomig/i3wm-debian/blob/main/LICENSE
###############################################################################
# This program is free software; you can redistribute it and/or modify# it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the# GNU General Public License for more details.
###############################################################################

# shellcheck source=./utils.bash
source ./utils.bash

# Create symbolic links to dotfiles in the home directory
link_dotfiles() {
	local -r old_configs=~/old-configs
	[[ -d "$old_configs" ]] || mkdir -p "$old_configs"
	local file
	local -r files=(
		.bash_aliases
		.bashrc
		.bash_logout
		.face
		.imwheelrc
		.inputrc
		.profile
	)
	printf "\e[93m93mLinking dotfiles ...\e[0m\n"
	for file in "${files[@]}"; do
		printf "\e[93mLinking %s ...\e[0m\n" "$file"
		[[ -f "$HOME/$file" ]] && mv -v "$HOME/$file" "$old_configs/"
		ln -sv ~/Downloads/configs/"$file" ~/"$file"
	done
	return 0
}

# Link specific configuration files to directories in ~/.config
link_configs() {
	local -r old_configs=~/old-configs
	[[ -d "$old_configs" ]] || mkdir -p "$old_configs"
	local config
	local -r configs=(
		"dunst/dunstrc"
		"flameshot/flameshot.ini"
		"glow/glow.yml"
		"micro/bindings.json"
		"micro/settings.json"
		"picom/picom.conf"
		"redshift.conf"
		"shellcheck/shellcheckrc"
	)
	for config in "${configs[@]}"; do
		if [[ -f "$HOME/Downloads/configs/$config" ]]; then
			printf "\e[93mLinking %s to %s ...\e[0m\n" "$HOME/Downloads/configs/$config" "$HOME/.config"
			if [[ "$config" == "redshift.conf" ]]; then
				mv -v "$HOME/.config/$config" "$old_configs/"
			else
				[[ -d "$old_configs/${config%/*}" ]] || mkdir -p "$old_configs/${config%/*}"
				mv -v "$HOME/.config/$config" "$old_configs/${config%/*}/${config##*/}"
			fi
			ln -sv ~/Downloads/configs/"$file" ~/.config/"$file"
		fi
	done
	micro -plugin install bookmark
	return 0
}

# Copy configuration directories to ~/.config
copy_configs(){
	local cfg_dir cfg_dirs
	cfg_dirs=(
		i3
		kitty
		keepassxc
		polybar
		rofi
		systemd
	)
	for cfg_dir in "${cfg_dirs[@]}"; do
		printf "\e[93mCopying %s ...\e[0m\n" "$cfg_dir"
		cp -rv "$HOME/Downloads/configs/$cfg_dir" "$HOME/.config"/
	done
	return 0
}

# Copy miscellaneous files
cp_ln_misc_files() {
	printf "\e[93mCopying miscellaneous files...\e[0m\n"
	cp -av ~/Downloads/configs/icons/. ~/.icons/
	ln -sv ~/Downloads/configs/backgrounds ~/.config/
	ln -sv ~/Downloads/configs/local/leave.txt ~/.local/share/doc/leave.txt
	return 0
}

# Configure the nano text editor
configure_nano() {
	printf "\e[93mConfiguring nano...\e[0m\n"
	cp -v /etc/nanorc ~/.config/nano/
	sed -i -f ~/bin/files/nano.sed ~/.config/nano/nanorc
	return 0
}

# Set reserved space for root and home partitions
set_reserved_space() {
	local home_part root_part data_part rbc blk_cnt res_pct
	root_part=$(awk '$NF == "/" {print $1}' <(df -P))
	home_part=$(awk '$NF == "/home" {print $1}' <(df -P))
	data_part=$(awk '$NF == "/data" {print $1}' <(df -P))
	rbc=$(awk '/Reserved block count/ {print $NF}' <(sudo /usr/sbin/tune2fs -l "$root_part"))
	blk_cnt=$(awk '/Block count/ {print $NF}' <(sudo /usr/sbin/tune2fs -l "$root_part"))
	res_pct="$(bc <<< "${rbc} * 100 / ${blk_cnt}")"
	printf "e[93mSetting reserved space on root & home partitions...\e[0m\n"
	[[ "$res_pct" -ne 5 ]] && sudo /usr/sbin/tune2fs -m 2 "$root_part"
	[[ "$home_part" ]] && sudo /usr/sbin/tune2fs -m 0 "$home_part"
	[[ "$data_part" ]] && sudo /usr/sbin/tune2fs -m 0 "$data_part"
	printf "Partition reserve space set.\n"
	return 0
}

# Add tweaks to /etc/sudoers.d directory and set swappiness
apply_system_tweaks() {
	local -r repo_dir=~/Downloads/configs
	printf "\e[93mApplying password feedback...\e[0m\n"
	sudo cp -v "$repo_dir"/sudoers/0pwfeedback /etc/sudoers.d/
	sudo chmod 440 /etc/sudoers.d/0pwfeedback
	printf "\e[93mApplying sudo timeout...\e[0m\n"
	sudo cp -v "$repo_dir"/sudoers/10-timeout /etc/sudoers.d/
	sudo chmod 440 /etc/sudoers.d/10-timeout
	printf "\e[93mDisabling snaps...\e[0m\n"
	sudo cp -v "$repo_dir"/apt/nosnap.pref /etc/apt/preferences.d/
	printf "\e[93mSetting swappiness...\e[0m\n"
	sudo cp -v "$repo_dir"/90-swappiness.conf /etc/sysctl.d/
	printf "\e[93mSetting sleep.conf...\e[0m\n"
	[[ -d /etc/systemd/sleep.conf.d ]] || sudo mkdir -p /etc/systemd/sleep.conf.d
	sudo cp -v "$repo_dir"/99-sleep.conf /etc/systemd/sleep.conf.d/
	set_reserved_space
	return 0
}

configure_polybar() {
	local -r conf=config.ini
	local -r polybar_dir=~/.config/polybar
	local eth_int wifi_int bat_name
	eth_int=$(awk -F/ '{print $NF}' < <(find /sys/class/net -name "e*"))
	wifi_int=$(awk -F/ '{print $NF}' < <(find /sys/class/net -name "w*"))
	bat_name=$(awk -F/ '{print $NF}' < <(find /sys/class/power_supply -name "BAT*"))
	# Remove list of device names when known to work
	[[ "$eth_int" ]] && printf "Ethernet: %s\n" "$eth_int" || printf "No ethernet interface detected.\n"
	[[ "$wifi_int" ]] && printf "Wireless: %s\n" "$wifi_int" || printf "No wireless interface detected.\n"
	[[ "$bat_name" ]] && printf "Battery:  %s\n" "$bat_name" || printf " No battery detected.\n"
	# Insert device names into modules
	if [[ "$eth_int" ]]; then
		sed -i "s/eth0/$eth_int/" "$polybar_dir/$conf"
	else
		sed -i '/^modules-left/s/ eth//' "$polybar_dir/$conf"
	fi
	if [[ "$wifi_int" ]]; then
		sed -i "s/wlan0/$wifi_int/" "$polybar_dir/$conf"
	else
		sed -i '/^modules-left/s/ wlan//' "$polybar_dir/$conf"
	fi
	if [[ "$bat_name" ]]; then
		sed -i "s/BAT0/$bat_name/" "$polybar_dir/$conf"
	else
		sed -i '/^modules-right/s/ battery//' "$polybar_dir/$conf"
	fi
	printf "polybar-i3 confgured.\n"
	return 0
}

main() {
	local -r script="${0##*/}"
	local -r version="3.3.26304"
	print_logo
	link_dotfiles
	link_configs
	copy_configs
	cp_ln_misc_files
	configure_nano
	apply_system_tweaks
	configure_polybar
	printf "\e[93mi3 Window Manager installation complete!\e[0m\n"
	printf "Reboot and login to i3.\n"
	over_line "$script $version"
	exit
}

main "$@"
