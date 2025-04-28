#!/usr/bin/env bash
###############################################################################
# Script Name  : utils.sh
# Description  : Utility functions for installing packages for Debian i3WM
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Last updated : 27 Apr 2025
# Version      : 1.0.25118
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
    	printf "\e[93mInstalling $pkg...\e0m\n"
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
	local cloned_dir="$HOME/Downloads/scripts"
	local bin_dir="$HOME/bin"
	[[ -d "$bin_dir" ]] || mkdir -p "$bin_dir"
	if [[ -d "$cloned_dir/scripts" ]]; then
		cp -rpv "$cloned_dir/scripts"/* "$bin_dir"
	else
		echo "Scripts directory not found." >&2
	fi
}
