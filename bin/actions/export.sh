#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh

printfe "%s\n" "cyan" "Exporting Gnome Terminal preferences"
dconf dump /org/gnome/terminal/ > ~/dotfiles/config/gterminal.preferences

printfe "%s\n" "cyan" "Exporting VSCode extensions"
code --list-extensions | jq -R -s -c 'split("\n")[:-1]' > ~/dotfiles/vscode/extensions.json

printfe "%s\n" "green" "Finished, don't forget to commit and push"