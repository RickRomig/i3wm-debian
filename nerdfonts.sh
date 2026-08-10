#!/usr/bin/env bash
###############################################################################
# Script Name  : nerdfonts.sh
# Description  : Installs Nerd Fonts to new i3WM installation.
# Dependencies : wget
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Updated      : 10 Aug 2026
# Version      : 2.8.26222
# Comments     : Run this script after install.sh and before configs.sh
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

# shellcheck disable=SC2317 # Don't warn about unreachable commands in this function
# ShellCheck may incorrectly believe that code is unreachable if it's invoked by variable name or in a trap.
cleanup() {
	[[ -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
}

install_NerdFonts() {
  local -r font_dir="$1"
  local -r font_repo="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0"
  local font fonts
  [[ -d "$font_dir" ]] || sudo mkdir -p "$font_dir"
  fonts=( "FiraCode" "Go-Mono" "Hack" "Inconsolata" "Iosevka" "JetBrainsMono" "Mononoki" "RobotoMono" "SourceCodePro" )
  for font in "${fonts[@]}"; do
    printf "\e[03mInstalling %s ...\e[0m\n" "$font"
    wget -q -P "$TMP_DIR" "$font_repo/$font.tar.xz"
    mkdir -p "$font_dir/$font/"
    tar -xvf "$TMP_DIR/${font}.tar.xz" -C "$font_dir/$font/"
  done
  printf "Nerd fonts installed.\n"
}

install_SymbolNerdFonts() {
  local -r font_dir="$1"
  cp -v ~/Downloads/configs/local/nerdfonts/*.ttf "$font_dir/"
  printf "Symbols Nerd Fonts installed.\n"
}

main() {
	local -r script="${0##*/}"
  local -r version="1.6.25364"
  local -r font_dir=~/.local/share/fonts
  TMP_DIR=$(mktemp -d) || { printf "\e[91mERROR:\e[0m: Failed to create temporary directory." >&2; exit 1; }
  trap cleanup EXIT
  install_NerdFonts "$font_dir"
  install_SymbolNerdFonts "$font_dir"
  fc-cache
	echo "-----------------"
	echo "$script $version"
  printf "Run \e[93mconfigs.sh\e[0m to setup configuration files and complete the installation.\n"
  exit
}

main "$@"
