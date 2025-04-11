#!/usr/bin/env bash
###############################################################################
# Script Name  : dmconf.sh
# Description  : select from a list of config files to edit
# Dependencies : dmenu
# Arguments    : None
# Author       : Copyright © 2023, Richard B. Romig, Mosfanet
# Email        : rick.romig@gmail.com | rick.romig@mymetronet.com
# Created      : 22 Nov 2023
# Last updated : 22 Nov 2023
# Comments     :
# TODO (Rick)  : 
# License      : GNU General Public License, version 2.0
###############################################################################

# Define text editor to use:
DMENUEDITOR="codium"

# array to choose from:
declare -a options=(
"aliases - $HOME/.bash_aliases"
"autostart - $HOME/.config/i3/autostart.sh"
"bashrc - $HOME/.bashrc"
"bat - $HOME/.config/bat/config"
"codium -$HOME/.config/VSCodium/User/settings.json"
"profile - $HOME/.profile"
"i3 - $HOME/.config/i3/config"
"kitty - $HOME/.config/kitty/kitty.conf"
"logout - $HOME/.config/i3/logout"
"micro - $HOME/.config/micro/settings.json"
"neofetch - $HOME/.config/neofetch/config.conf"
"polybar - $HOME/.config/polybar/config.ini"
"sxhkdrc - $HOME/.config/i3/sxhkd/sxhkdrc"
"workspaces - $HOME/.config/i3/workspaces.conf"
"quit"
)

# Pipe the array into dmenu
choice=$(printf '%s\n' "${options[@]}" | dmenu -i -l 15 -p 'Edit config:')

if [[ "$choice" == "quit" ]]; then
	echo "Program terminated." && exit 1
elif [[ "$choice" ]]; then
	cfg=$(printf '%s\n' "${choice}" | awk '{print $NF}')
	"$DMENUEDITOR" "$cfg"
else
	echo "Program terminated." && exit 1
fi
