#!/usr/bin/env bash
###############################################################################
# Script Name  : utils.sh
# Description  : Utility functions for installing packages for Debian i3WM
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Last updated : 22 May 2025
# Version      : 1.1.25142
# Comments     :
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
###############################################################################

# Function to check if a package is installed
is_installed() {
	dpkg -l "$1" &> /dev/null && return 0 || return 1
}

# Function to install packages if not already installed
install_packages() {
  local packages=("$@")
  local to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_installed "$pkg"; then
    	to_install+=("$pkg")
    fi
  done

  if [ ${#to_install[@]} -ne 0 ]; then
    for pkg in "${to_install[@]}"; do
    	printf "\e[93mInstalling %s...\e[0m\n" "$pkg"
    	sudo apt-get install -yy "$pkg"
    done
  fi
}

clone_repos() {
	local dl_dir repo repos repo_url
	repo_url="https://github.com/RickRomig"
	repos=(configs scripts)
	dl_dir="$HOME/Downloads"
	printf "\e[93mCloning configs and scripts...\e[0m\n"
	for repo in "${repos[@]}"; do
		if [[ -d "$dl_dir/$repo" ]]; then
			echo "$repo repository already exists."
		else
			git clone "$repo_url/$repo.git" "$dl_dir/$repo"
		fi
	done
}

copy_scripts() {
	local response
	read -rp "Copy scripts or create a link? (c/l) " response
	if [[ "$response" =~ ^[Cc]$ ]]; then
		printf "\e[93mCopying scripts to ~/bin ...\e[0m\n"
		cp -rpv "$HOME/Downloads/scripts/*" "$HOME/bin/"
	elif [[ "$response" =~ ^[Ll]$ ]]; then
		printf "\e[93mCreating symbolic link to scripts directory...\e[0\n"
		ls -s "$HOME/Downloads/scripts" "$HOME/bin/"
	else
		printf "\e[93mCopying scripts to ~/bin ...\e[0m\n"
		cp -rpv "$HOME/Downloads/scripts/*" "$HOME/bin/"
	fi
}
