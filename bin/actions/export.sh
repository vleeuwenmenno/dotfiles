#!/usr/bin/env bash

source $HOME/dotfiles/bin/helpers/functions.sh

printfe "%s\n" "cyan" "Exporting GNOME extensions"
source $HOME/dotfiles/bin/helpers/gnome_extensions.sh
export_gnome_extensions

printfe "%s\n" "cyan" "Exporting VSCode extensions"
code --list-extensions | jq -R -s -c 'split("\n")[:-1]' > ~/dotfiles/vscode/extensions.json

printfe "%s\n" "cyan" "Exporting gnome-terminal settings"
dconf dump /org/gnome/terminal/ > ~/dotfiles/config/gnome-terminal.dconf

printfe "%s\n" "green" "Finished, don't forget to commit and push"