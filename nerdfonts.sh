#!/usr/bin/env bash
###############################################################################
# Script Name  : nerdfonts.sh
# Description  : Installs Nerd Fonts to new i3WM installation.
# Dependencies : wget
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Last updated : 03 May 2025
# Comments     : Run this script after run.sh.
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
###############################################################################

# shellcheck disable=SC2317 # Don't warn about unreachable commands in this function
# ShellCheck may incorrectly believe that code is unreachable if it's invoked by variable name or in a trap.
cleanup() {
	[[ -d "$tmp_dir" ]] && rm -rf "$tmp_dir"
}

install_nerd_fonts() {
  local font font_dir fonts font_repo
  font_repo="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0"
  font_dir="/usr/local/share/fonts"
  [[ -d "$font_dir" ]] || sudo mkdir -p "$font_dir"
  fonts=( "CascadiaCode" "FiraCode" "Go-Mono" "Hack" "Inconsolata" "Iosevka" "JetBrainsMono" "Mononoki" "RobotoMono" "SourceCodePro" )
  for font in "${fonts[@]}"; do
    printf "\e[03mInstalling %s ...\e[0m\n" "$font"
    wget -P "$tmp_dir" "$font_repo/$font.tar.xz"
    sudo mkdir -p "$font_dir/$font/"
    sudo tar -xvf "$tmp_dir/$font.tar.xz" -C "$font_dir/$font/"
  done
  fc-cache
  printf "Nerd fonts installed.\n"
}

main() {
  local script version
  script=$(basename "$0")
  version="1.0.25123"
  tmp_dir=$(mktemp -d) || { printf "\e[91mERROR:\e[0m: Failed to create temporary directory." >&2; exit 1; }
  trap cleanup EXIT
  install_nerd_fonts
	echo "-----------------"
	echo "$script $version"
  printf "Run \e[93mconfigs.sh\e[0m to setup configuratino files and complete the installation.\n"
  exit
}

main "$@"
