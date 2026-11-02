#!/usr/bin/env bash
###############################################################################
# Script Name  : install.sh
# Description  : Installs i3-wm on a minimal installation of Debian 13 or Devuan 6
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Updated      : 02 Nov 2026
# Version      : 3.2.26306
# Comments     : Run this script first.
#              : Supports Debian 13 (Trixie) and Devuan 6 (Excalibur)
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
# shellcheck source=./packages.conf
source ./utils.bash
source ./packages.conf

# Install Spice Tools if a virtual machine
vm_spice_install() {
	if [[ ! -b /dev/vda ]]; then
		printf "Not a virtual machine. Spice agents not installed.\n" >&2
		return 1
	fi
	local -r agents=(spice-vdagent spice-webdavd)
	local agent
	local -i code=0
	printf "Install spice-vdagent & spice-webdavd on a Virtual Machine...\n"
	for agent in "${agents[@]}"; do
		sudo apt-get install -y "$agent"
		if ! is_installed "$agent"; then
			printf "\e[91mERROR:\e[0m %s installation failed.\n" "$agent"
	 		code=1
		fi
	done
	return "$code"
}

# Install ZRAM Tools (Swap partition should NOT have been created during install)
install_zram() {
	if grep -q -E 'file|partition' /proc/swaps; then
		printf "A swap file or partition already exists.\n" >&2
		return 1
	fi
	printf "\e[93mInstalling Z-Ram...\e[0m\n"
	sudo apt install -y zram-tools
	# sudo sed -i.bak -f ~/Downloads/scripts/files/zramswap.sed /etc/default/zramswap
	sudo cp -v ~/Downloads/configs/zramswap /etc/default/zramswap
	sudo systemctl restart zramswap.service
	printf "Zram-tools installed.\n"
	return 0
}

# Install AMD or Intell microcode
install_microcode() {
	local vendor_id
	vendor_id=$(awk '/Vendor ID:/ {print $NF}' < <(lscpu))
	printf "\e[93mInstalling microcode for %s ...\e[0m\n" "$vendor_id"
	case "$vendor_id" in
		AuthenticAMD )
			is_installed amd64-microcode || sudo apt-get install -y amd64-microcode
			printf "AMD 64 microcode installed.\n" ;;
		GenuineIntel )
			is_installed intel-microcode || sudo apt-get install -y intel-microcode
			printf "Intel microcode installed.\n" ;;
		* )
			printf "\e[91mWARNING!\e[0m %s CPU not supported.\n" "$vendor_id" >&2
			return 1
	esac
	return 0
}

install_bluetooth() {
	printf "\e[93mInstalling Bluetooth...\e[0m\n"
	is_installed bluez || sudo apt install -y bluez
	is_installed blueman || sudo apt install -y blueman
	sudo systemctl enable bluetooth
	return "$?"
}

# Install disk utilities as required
install_disk_utils() {
	if [[ -b /dev/vda ]]; then
		printf "\e[91mVirtual machine, disk utillities were not installed.\e[0m\n"
		return 0
	fi
	if [[ -b /dev/sda ]]; then
		printf "\e[93mInstalling hdparm...\e[0m\n"
		is_installed hdparm || sudo apt install -y hdparm
	fi
	if [[ -c /dev/nvme0 ]]; then
		printf "\e[93mInstalling nvme-cli...\e[0m\n"
		is_installed nvme-cli || sudo apt install -y nvme-cli
	fi
	return "$?"
}

# Configure login manager
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
	return "$?"
}

# Check for distribution, virtual machine, apt updates, moderinzed sources
pre_install() {
	local distro
	distro="$(/usr/bin/lsb_release --codename --short 2>/dev/null)"
	if [[ "$distro" != "excalibur" && "$distro" != "trixie" ]]; then
		printf "\e[91m%s is not supported.\e[0m\nInstalls i3wm on Debian 13 or Devuan 6 only.\n" "${distro^}" >&2
		exit 1
	fi
	vm_spice_install
	printf "\e[93mUpdating the system...\e[0m\n"
	# sudo find /etc/apt -name "*.list" -exec sed -i 's/http:/https:/;/ftp/s/https:/http:/' {} \;
	[[ -f /etc/apt/sources.list.d/debian-sources ]] || sudo apt modernize-sources
	sudo apt-get update && sudo apt-get dist-upgrade -y && sudo apt-get clean
	return "$?"
}

# Prepare for i3 iinstallation
initial_setup() {
	install_microcode
	grep -i blue < <(lsusb) && install_bluetooth
	printf "\e[93mSetting up directories...\e[0m\n"
	xdg-user-dirs-update
	mkdir -pv ~/.cache ~/.icons ~/Screenshots
	mkdir -pv ~/.config/{backgrounds,dunst,flameshot,i3,keepassxc,kitty,micro,nano,picom,polybar,rofi,systemd/user}
	mkdir -pv ~/.local/{bin,state,share/{doc,fonts,logs,icons}}
	mkdir -pv ~/.ssh && chmod 700 ~/.ssh
	clone_repos
	install_zram
	return "$?"
}

# Install applilcations using packages.conf
install_by_category() {

	printf "\e[93mInstalling Core packages...\e[0m\n"
	install_packages "${CORE_PACKAGES[@]}"
	sleep 5

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
	return 0
}

# Enable systemd servies
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
	return "$?"
}

main() {
	local -r script="${0##*/}"
	local -r version="3.0.26304"
	local confirm
	local re="^[Yy]$"
	clear
	print_logo
	printf "This script will install i3wm, configuration files, and scripts on your Debian system.\n"
	read -rp "Do you want to continue (y/n) " confirm
	[[ ! $confirm =~ $re ]] && { printf "Installation canceled.\n" >&2; exit; }
	pre_install
	initial_setup
	install_by_category
	configure_lightdm
	enable_services
	link_scripts
	printf "Run \e[93mnerdfonts.sh\e[0m and \e[93mconfigs.sh\e[0m to install Nerd Fonts and configuration files.\n"
	over_line "$script $version"
	exit
}

main "$@"
