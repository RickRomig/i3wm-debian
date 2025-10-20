#!/usr/bin/env bash
###############################################################################
# Script Name  : utils.sh
# Description  : Utility functions for installing packages for Debian i3WM
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Last updated : 20 Oct 2025
# Version      : 1.6.25293
# Comments     : Sourced in install.sh
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
    	sudo apt-get install -yy "$pkg" 2>/dev/null || printf "\e[32m%s not installed, skipping...\e[0m\n" "$pkg"
    done
  fi
}

# Clone configs and scripts repositories to ~/Downloads
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

# Copy scripts to ~/bin
link_scripts() {
	printf "\e[93mLinking scripts to ~/bin...\e[0m\n"
	ln -vs ~/Downloads/scripts/ ~/bin
	# printf "\e[93mCopying scripts to ~/bin ...\e[0m\n"
	# cp -rpv "$HOME/Downloads/scripts/" "$HOME/bin/"
	# [[ -d "$HOME/bin" ]] && rm -rf "${HOME:?}/bin"
}
