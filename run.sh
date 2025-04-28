#!/usr/bin/env bash
###############################################################################
# Script Name  : run.sh
# Description  : Installs i3-wm on a minimal installation of Debin along with applications, untilities, etc.
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Last updated : 27 Apr 2025
# Comments     : Adapted from Crucible by typecraft
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
###############################################################################
# shellcheck disable=SC1090

set -e

source utils.sh

## Functions ##

print_logo() {
	cat << "LOGO"
  __  __            __       _   _      _
 |  \/  | ___  ___ / _| __ _| \ | | ___| |_
 | |\/| |/ _ \/ __| |_ / _` |  \| |/ _ \ __|
 | |  | | (_) \__ \  _| (_| | |\  |  __/ |_
 |_|  |_|\___/|___/_|  \__,_|_| \_|\___|\__|
 Debian i3WM Installation Tool by The Luddite Geek
LOGO
}

check_vm() {
	local localnet
	localnet=$(ip route get 1.2.3.4 | cut -d' ' -f3 | sed 's/\..$//')
	if [[ "$localnet" == "196.168.122" ]] || [[ "$localnet" == "10.0.2" ]]; then
		apt-get install spice-vdagent spice-webdavd
	fi
}

install_zram() {
	sudo apt install -y zram-tools
	sudo sed -i.bak '/ALGO/s/^#//;/PERCENT/s/^#//;s/50$/25/' /etc/default/zramswap
  sudo systemctl restart zramswap.service
	printf "Zram-tools installed.\n"
}

install_microcode() {
	local vendor_id
	vendor_id=$(lscpu | awk '/Vendor ID:/ {print $NF}')
	printf "Installing microcode for %s ...\n" "$vendor_id"
	case "$vendor_id" in
		AuthenticAMD )
			sudo apt-get install -y amd64-microcode
			printf "AMD 64 microcode installed.\n" ;;
		GenuineIntel )
			sudo apt-get install -y intel-microcode
			printf "Intel microcode installed.\n" ;;
		* )
			printf "%s CPU not supported.\n" "$vendor_id"
	esac
}

install_bluetooth() {
	printf "Installing Bluetooth...\n"
	sudo apt install -y bluez blueman
	sudo systemctl enable bluetooth
}

install_disk_utils() {
	if [[ -b /dev/sda ]]; then
		sudo apt install -y hdparm
	elif [[ -c /dev/nvme0 ]]; then
		sudo apt install -y nvme-cli
	else
		echo "Virtual machine"
	fi
}

setup_lightdm() {
	printf "Installing lightdm and slick-greeter ...\n"
	# Show users on lightdm greeter screen
	sudo sed -i '/#greeter-hide-users=/s/^#//' /etc/lightdm/lightdm.conf
	# Append slick-greeter to lightdm.conf
	sudo sed -i '/^#greeter-session=example-gtk-gnome/a greeter-session=slick-greeter' /etc/lightdm/lightdm.conf
	# Add slick-greeter.conf to /etc/lightdm/
	sudo cp slick-greeter.conf /etc/lightdm/
	# Add background image for login screen
	[[ -d /usr/share/backgrounds ]] || sudo mkdir -p /usr/share/backgrounds
	sudo cp solarized-debian.png /usr/share/backgrounds/slickback.png
	# XSessions & i3.desktop
	[[ -d /usr/share/xsessions ]] || sudo mkdir -p /usr/share/xsessions
	sudo cp i3.desktop /usr/share/xsessions/
}

initial_setup() {
	lsblk | grep -iw swap || install_zram
	install_microcode
	lsusb | grep -i blue && install_bluetooth
	xdg-user-dirs-update
	mkdir -p ~/bin ~/.cache ~/.config
	mkdir -p ~/.local/{bin,state,share/{doc,logs,icons/battery}}
	mkdir -p ~/.ssh && chmod 700 ~/.ssh
	clone_repos
}

install_by_category() {

	echo "Installing system utilities..."
	install_packages "${SYSTEM_UTILS[@]}"
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	echo "Installing network utilities..."
	install_packages "${NETWORK_UTILS[@]}"
	sudo sed -i.bak '/managed/s/false/true/' /etc/NetworkManager/NetworkManager.conf

	echo "Installing X packages..."
	install_packages "${X_PACKAGES[@]}"

	echo "Installing printer tools..."
	install_packages "${PRINTER_TOOLS[@]}"

	echo "Installing development tools..."
	install_packages "${DEV_TOOLS[@]}"

	echo "Installing system maintenance tools..."
	install_packages "${MAINTENANCE[@]}"
	install_disk_utils

	echo "Installing desktop environment..."
	install_packages "${DESKTOP[@]}"

	echo "Installing desktop environment..."
	install_packages "${OFFICE[@]}"

	echo "Installing media packages..."
	install_packages "${MEDIA[@]}"

	echo "Installing fonts..."
	install_packages "${FONTS[@]}"

	echo "Installing display manager..."
	install_packages "${LIGHTDM[@]}"
}

enable_services() {
	local service
	echo "Configuring services..."
	for service in "${SERVICES[@]}"; do
	  if ! systemctl is-enabled "$service" &> /dev/null; then
	    echo "Enabling $service..."
	    sudo systemctl enable "$service"
	  else
	    echo "$service is already enabled"
	  fi
	done
}

main() {
	local script version
	script="$(basename "$0")"
	version="2.0.25118"
	check_vm
	clear
	print_logo
	if [[ -f "packages.conf" ]]; then
		source packages.conf
	else
		echo "Error: packages.conf not found!"
		exit 1
	fi
	echo "Updating the system..."
	sudo apt-get update

	initial_setup
	install_by_category
	setup_lightdm
	enable_services
	copy_scripts
	bash ~/i3wm-debian/nerdfonts.sh
	bash ~/i3wm-debian/configs.sh

	echo "Setup complete! Reboot your system."
	echo "$script $version"
	exit
}

## Execution ##

main "$@"
