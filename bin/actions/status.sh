#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh
source ~/dotfiles/bin/helpers/apt_packages.sh
source ~/dotfiles/bin/helpers/vscode-extensions.sh
source ~/dotfiles/bin/helpers/cargo_packages.sh
source ~/dotfiles/bin/helpers/flatpak_packages.sh
source ~/dotfiles/bin/helpers/keyboard_shortcuts.sh

# Check if parameter --verbose was passed
if [ "$2" = "--verbose" ]; then
    verbose=true
else
    verbose=false
fi

echo -e "\n"

print_keyboard_shortcuts_status
print_apt_status
print_cargo_status
print_flatpak_status
print_vsc_status
