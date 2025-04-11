#!/usr/bin/env bash
###############################################################################
# Script Name  : run.sh
# Description  : Installs i3-wm on a minimal installation of Debin along with applications, untilities, etc.
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Last updated : 10 Apr 2025
# Comments     : Adapted from Crucible by typecraft
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
###############################################################################
# shellcheck disable=SC1090

set -e

source utils.sh

## Global variables ##

## Functions ##

print_logo() {
	cat << "LOGO"
  __  __            __       _   _      _
 |  \/  | ___  ___ / _| __ _| \ | | ___| |_
 | |\/| |/ _ \/ __| |_ / _` |  \| |/ _ \ __|
 | |  | | (_) \__ \  _| (_| | |\  |  __/ |_
 |_|  |_|\___/|___/_|  \__,_|_| \_|\___|\__|
 Debian i3WM Installation Tool
LOGO
}

install_zram() {
	sudo apt install -y zram-tools
	sudo sed -i.bak '/ALGO/s/^#//;/PERCENT/s/^#//;s/50$/25/' /etc/default/zramswap
  sudo systemctl restart zramswap.service
	printf "Zram-tools installed.\n"
}

install_microcode() {
	local vendor_id
	vendor_id=$(lcpu | awk '/Vendor ID:/ {print $NF}')
	printf "Installing microcode for %s ...\n" "$vendor_id"
	case "$vendor_id" in
		AuthenticAMD )
			sudo apt-get install -y amd64-microcode
			printf "AMD 64 microcode install.\n"
		;;
		GenuineIntel )
			sudo apt-get install -y intel-microcode
			printf "Intel microcode installed.\n"
		;;
		* )
			printf "%s CPU not supported.\n" "$vendor_id"
	esac
}

install_bluetooth() {
	printf "Installing Bluetooth...\n"
	sudo apt install -y bluez blueman
	sudo systemctl enable bluetooth
}

install_flatpak() {
	printf "Installing Flatpak and Flathub ...\n"
	sudo apt install flatpak -yy
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

install_lightdm() {
	printf "Installing lightdm and slick-greeter ...\n"
	sudo apt install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings slick-greeter
	# Show users on lightdm greeter screen
	sudo sed -i '/#greeter-hide-users=/s/^#//' /etc/lightdm/lightdm.conf
	# Add slick-greeter to lightdm.conf
	sudo sed -i '/^#greeter-session=example-gtk-gnome/a greeter-session=slick-greeter' /etc/lightdm/lightdm.conf
	#  Add slick-greeter.conf
	sudo cp slick-greeter.conf /etc/lightdm/
	# Add /usr/share/backgrounds
	[[ -d /usr/share/backgrounds ]] || sudo mkdir -p /usr/share/backgrounds
	sudo cp solarized-debian.png /usr/share/backgrounds/slickback.png
	# XSessions
	[[ -d /usr/share/xsessions ]] || sudo mkdir -p /usr/share/xsessions
	sudo systemctl enable lightdm
	sudo cp i3.desktop /usr/share/xsessions/
}

main() {
	local script version
	script="$(basename "$0")"
	version="1.0.25100"
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

	# Initial setup
	lsblk | grep -iw swap || install_zram
	install_microcode
	lsusb | grep -i blue && install_bluetooth
	xdg-user-dirs-update
	mkdir -p ~/bin .cache .config .ssh
	mkdir -p ~/.local/{bin,state,share/{doc,logs,icons/battery}}
	chmod 700 ~/.ssh
	clone_repos

	# Install packages by category
	echo "Installing system utilities..."
	install_packages "${SYSTEM_UTILS[@]}"

	echo "Installing network utilities..."
	install_packages "${NETWORK_UTILS[@]}"
	sudo sed -i.bak '/managed/s/false/true/' /etc/NetworkManager/NetworkManager.conf

	echo "Installing X packages..."
	install_packages "${X_PACKAGES[@]}"

	echo "Installing printer tools..."
	install_packages "${PRINTER_TOOLS[@]}"

	echo "Installing productivity applications"
	install_packages "${PROD_APPS[@]}"

	# echo "Installing development tools..."
	# install_packages "${DEV_TOOLS[@]}"

	echo "Installing system maintenance tools..."
	install_packages "${MAINTENANCE[@]}"

	echo "Installing desktop environment..."
	install_packages "${DESKTOP[@]}"

	# echo "Installing desktop environment..."
	# install_packages "${OFFICE[@]}"

	echo "Installing media packages..."
	install_packages "${MEDIA[@]}"

	echo "Installing fonts..."
	install_packages "${FONTS[@]}"

	install_lightdm
	install_flatpak

	# Enable services
	echo "Configuring services..."
	for service in "${SERVICES[@]}"; do
	  if ! systemctl is-enabled "$service" &> /dev/null; then
	    echo "Enabling $service..."
	    sudo systemctl enable "$service"
	  else
	    echo "$service is already enabled"
	  fi
	done

	# Miscelleous operations
	# Copy scripts to ~/bin
	[[ -d ~/bin ]] || mkdir -p ~/bin
	cp -rpv ~/Downloads/scripts/* ~/bin/
	# Install Nerd Fonts
	source ~/i3wm-debian/nerdfonts.sh
	# Copy configuration files
	source ~/i3wm-debian/copyconf.sh

	echo "Setup complete! Reboot your system."
	echo "$script $version"
	exit
}

## Execution

main "$@"
