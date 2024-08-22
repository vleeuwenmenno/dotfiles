#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh

printfe "%s\n" "cyan" "Exporting Gnome Terminal preferences"
dconf dump /org/gnome/terminal/ > ~/dotfiles/config/gterminal.preferences

printfe "%s\n" "green" "Finished, don't forget to commit and push"