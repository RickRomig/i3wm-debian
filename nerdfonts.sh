#!/usr/bin/env bash
###############################################################################
# Script Name  : nerdfonts.sh
# Description  : Installs Nerd Fonts to new i3WM installation.
# Dependencies : None
# Arguments    : None
# Author       : Copyright © 2025, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 10 Apr 2025
# Last updated : 11 Apr 2025
# Comments     :
# TODO (Rick)  :
# License      : GNU General Public License, version 2.0
###############################################################################

# shellcheck disable=SC2317 # Don't warn about unreachable commands in this function
# ShellCheck may incorrectly believe that code is unreachable if it's invoked by variable name or in a trap.
cleanup() {
	[[ -d "$tmp_dir" ]] && rm -rf "$tmp_dir"
}

script="$(basename "$0")"; readonly script
readonly version="1.0.25101"
readonly font_repo="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0"
readonly font_dir="/usr/local/share/fonts"
[[ -d "$font_dir" ]] || sudo mkdir -p "$font_dir"
tmp_dir=$(mktemp -d) || { printf "ERROR: Failed to create temporary directory.\n" >&2; exit 1; }

trap cleanup EXIT

fonts=(
"CascadiaCode"
"FiraCode"
"Go-Mono"
"Hack"
"Inconsolata"
"Iosevka"
"JetBrainsMono"
"Mononoki"
"RobotoMono"
"SourceCodePro"
)

for font in "${fonts[@]}"; do
	wget -P "$tmp_dir" "$font_repo/$font.tar.xz"
	sudo tar xvf "$tmp_dir/$font.zip" -C "$font_dir/$font/"
done
fc-cache
echo "-----------------"
echo "$script $version"
exit
