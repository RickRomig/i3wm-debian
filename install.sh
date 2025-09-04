#!/usr/bin/env bash
###############################################################################
# Script Name  : install.sh
# Description  : Installs i3-wm on a minimal installation of Debin along with applications, untilities, etc.
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Last updated : 04 Sep 2025
# Comments     : Run this script first.
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
# License URL  : https://github.com/RickRomig/i3wm-debian/blob/main/LICENSE
###############################################################################
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
###############################################################################

# shellcheck disable=SC1090

## Functions ##

print_logo() {
	echo -ne "\033[0;92m"
	cat << "LOGO"
  __  __            __       _   _      _
 |  \/  | ___  ___ / _| __ _| \ | | ___| |_
 | |\/| |/ _ \/ __| |_ / _` |  \| |/ _ \ __|
 | |  | | (_) \__ \  _| (_| | |\  |  __/ |_
 |_|  |_|\___/|___/_|  \__,_|_| \_|\___|\__|
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |i|3|w|m| |I|n|s|t|a|l|l|a|t|i|o|n|
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
     |T|h|e| |L|u|d|d|i|t|e| |G|e|e|k| |
     +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
LOGO
	echo -e "\033[0m"
}

source_files() {
	local file files status
	status=0
	files=(utils.sh packages.conf)
	for file in "${files[@]}"; do
		if [[ -f "$file" ]]; then
    	printf "%s [OK]\n" "$file"
    	sleep 1
    	printf '\e[A\e[K'
			source "$file"
		else
			printf "\e[91m%s not found.\e[0m\n" "$file" >&2
			status=1
		fi
		return "$status"
	done
}

vm_spice_install() {
	local localnet
	localnet=$(ip route get 1.2.3.4 | cut -d' ' -f3 | sed 's/\..$//')
	if [[ "$localnet" == "196.168.122" ]] || [[ "$localnet" == "10.0.2" ]]; then
		printf "\e[93mVirtual Machine - Installing guest additions...\e[0m\n"
		sudo apt-get install -y spice-vdagent spice-webdavd
	fi
}

install_zram() {
	printf "\e[93mInstalling Z-Ram...\e[0m\n"
	sudo apt install -y zram-tools
	sudo sed -i.bak '/ALGO/s/^#//;/PERCENT/s/^#//;/PERCENT/s/50$/25/' /etc/default/zramswap
  sudo systemctl restart zramswap.service
	printf "Zram-tools installed.\n"
}

install_microcode() {
	local vendor_id
	vendor_id=$(lscpu | awk '/Vendor ID:/ {print $NF}')
	printf "\e[93mInstalling microcode for %s ...\e[0m\n" "$vendor_id"
	case "$vendor_id" in
		AuthenticAMD )
			sudo apt-get install -y amd64-microcode
			printf "AMD 64 microcode installed.\n" ;;
		GenuineIntel )
			sudo apt-get install -y intel-microcode
			printf "Intel microcode installed.\n" ;;
		* )
			printf "\e[91mWARNING!\e[0m %s CPU not supported.\n" "$vendor_id" >&2
	esac
}

install_bluetooth() {
	printf "\e[93mInstalling Bluetooth...\e[0m\n"
	sudo apt install -y bluez blueman
	sudo systemctl enable bluetooth
}

install_disk_utils() {
	if [[ -b /dev/vda ]]; then
		printf "\e[91mVirtual machine, disk utillities were not installed.\e[0m\n"
	else
		[[ -b /dev/sda ]] && { rintf "\e[93mInstalling hdparm...\e[0m\n"; sudo apt install -y hdparm; }
		[[ -c /dev/nvme0 ]] && { printf "\e[93mInstalling nvme-cli...\e[0m\n"; sudo apt install -y nvme-cli; }
	fi
}

configure_lightdm() {
	printf "\e[93mConfiguring lightdm and slick-greeter ...\e[0m\n"
	# Show users on lightdm greeter screen
	sudo sed -i '/#greeter-hide-users=/s/^#//' /etc/lightdm/lightdm.conf
	# Append slick-greeter to lightdm.conf
	sudo sed -i '/^#greeter-session=example-gtk-gnome/a greeter-session=slick-greeter' /etc/lightdm/lightdm.conf
	# Add slick-greeter.conf to /etc/lightdm/
	sudo cp slick-greeter.conf /etc/lightdm/
	# Add background image for login screen
	[[ -d /usr/share/backgrounds ]] || sudo mkdir -p /usr/share/backgrounds
	sudo cp slickback.png /usr/share/backgrounds/
	# XSessions & i3.desktop
	[[ -d /usr/share/xsessions ]] || sudo mkdir -p /usr/share/xsessions
	sudo cp i3.desktop /usr/share/xsessions/
}

initial_setup() {
	lsblk | grep -iw swap || install_zram
	install_microcode
	lsusb | grep -i blue && install_bluetooth
	printf "\e[93mSetting up directories...\e[0m\n"
	xdg-user-dirs-update
	mkdir -pv ~/.cache ~/.icons ~/Screenshots
	mkdir -pv ~/.config/{backgrounds,dunst,flameshot,i3,keepassxc,kitty,micro,nano,picom,polybar,rofi,systemd/user}
	mkdir -pv ~/.local/{bin,state,share/{doc,fonts,logs,icons}}
	mkdir -pv ~/.ssh && chmod 700 ~/.ssh
	clone_repos
}

install_by_category() {

	printf "\e[93mInstalling Core packages...\e[0m\n"
	install_packages "${CORE_PACKAGES[@]}"

	printf "\e[93mInstalling system utilities...\e[0m\n"
	install_packages "${SYSTEM_UTILS[@]}"
	printf "\e[93mInstalling flathub...\e[0m\n"
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	printf "\e[93mInstalling network utilities...\e[0m\n"
	install_packages "${NETWORK_UTILS[@]}"
	sudo sed -i.bak '/managed/s/false/true/' /etc/NetworkManager/NetworkManager.conf

	printf "\e[93mInstalling File manager packages...\e[0m\n"
	install_packages "${FILE_MANAGER[@]}"

	printf "\e[93mInstalling Audio packages...\e[0m\n"
	install_packages "${AUDIO[@]}"

	printf "\e[93mInstalling printer tools...\e[0m\n"
	install_packages "${PRINTER_TOOLS[@]}"

	printf "\e[93mInstalling development tools...\e[0m\n"
	install_packages "${DEV_TOOLS[@]}"

	printf "\e[93mInstalling system maintenance tools...\e[0m\n"
	install_packages "${MAINTENANCE[@]}"
	install_disk_utils

	printf "\e[93mInstalling desktop environment...\e[0m\n"
	install_packages "${DESKTOP[@]}"

	printf "\e[93mInstalling office applications...\e[0m\n"
	install_packages "${OFFICE[@]}"

	printf "\e[93mInstalling media packages...\e[0m\n"
	install_packages "${MEDIA[@]}"

	printf "\e[93mInstalling fonts...\e[0m\n"
	install_packages "${FONTS[@]}"

	printf "\e[93mInstalling display manager...\e[0m\n"
	install_packages "${LIGHTDM[@]}"
}

enable_services() {
	local service
	printf "\e[93mConfiguring services...\e[0m\n"
	for service in "${SERVICES[@]}"; do
	  if ! systemctl is-enabled "$service" &> /dev/null; then
	    printf "\e[93mEnabling %s...\e[0m\n" "$service"
	    sudo systemctl enable "$service"
	  else
	    printf "%s is already enabled\n" "$service"
	  fi
	done
}

pre_install() {
	local distro
	distro="$(/usr/bin/lsb_release --codename --short | awk 'NR = 1 {print $0}')"
	source_files || exit 1
	[[ "$distro" == "bookworm" || "$distro" == "trixie" ]] || { printf "\e[91m%s is unsupported.\e[0m\nInstalls i3wm on Debian 12 or 13.\n" "${distro^}" >&2; exit 1; }
	printf "Install spice-vdagent & spice-webdavd if a Virtual Machine...\n"
	vm_spice_install
	printf "\e[93mUpdating the system...\e[0m\n"
	sudo find /etc/apt -name "*.list" -exec sed -i 's/http:/https:/;/ftp/s/https:/http:/' {} \;
	sudo apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get clean
}

main() {
	local -r script="${0##*/}"
	local -r version="2.0.25247"
	local confirm
	clear
	print_logo
	printf "This script will install i3wm, configuration files, and scripts on your Debian system.\n"
	read -rp "Do you want to continue (y/n) " confirm
	[[ ! "$confirm" =~ ^[Yy]$ ]] && { printf "Installation canceled.\n" >&2; exit; }
	pre_install
	initial_setup
	install_by_category
	configure_lightdm
	enable_services
	link_scripts
	printf "Run \e[93mnerdfonts.sh\e[0m and \e[93mconfigs.sh\e[0m to install Nerd Fonts and configuration files.\n"
	echo "$script $version"
	exit
}

## Execution ##

main "$@"
