#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh

printfe "%s\n" "cyan" "Pulling latest changes..."
git -C ~/dotfiles pull

if [ $? -ne 0 ]; then
  printfe "%s\n" "red" "Failed to pull latest changes"
  exit 1
fi

printfe "%s\n" "cyan" "Updating symlinks..."
check_or_make_symlink ~/.zshrc ~/dotfiles/zshrc
check_or_make_symlink ~/.config/Code/User/settings.json ~/dotfiles/vscode/settings.json
check_or_make_symlink ~/.config/starship.toml ~/dotfiles/config/starship.toml

printfe "%s\n" "cyan" "Ensuring packages are installed..."
source ~/dotfiles/bin/helpers/packages.sh
ensure_packages_installed

printfe "%s\n" "cyan" "Ensuring VSCode extensions are installed..."
source ~/dotfiles/bin/helpers/vscode-extensions.sh
ensure_vscode_extensions_installed

printfe "%s\n" "cyan" "Importing Gnome Terminal preferences..."
cat ~/dotfiles/config/gterminal.preferences | dconf load /org/gnome/terminal/legacy/profiles:/

printfe "%s\n" "green" "Finished, don't forget restart your terminal"
