#!/usr/bin/env bash
###############################################################################
# Script Name  : utils.sh
# Description  : Utility functions for installing packages for Debian i3WM
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Last updated : 25 Apr 2025
# Version      : 1..25115
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
    	echo "Installing $pkg..."
    	apt-get install -yy "$pkg"
    done
  fi
}

clone_repos() {
	# local gitea_url="http://192.168.0.16:3000/Nullifidian"
	local repo_url="https://github.com/RickRomig"
	local repos=(configs scripts)
	local dl_dir="$HOME/downloads"

	for repo in "${repos[@]}"; do
		if [[ -d "$dl_dir/$repo" ]]; then
			echo "$repo repository already exists."
		else
			git clone "$repo_url/$repo.git" "$dl_dir/$repo"
		fi
	done
}
