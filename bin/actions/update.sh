#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh

printfe "%s\n" "cyan" "Pulling latest changes..."
git -C ~/dotfiles pull

if [ $? -ne 0 ]; then
  printfe "%s\n" "red" "Failed to pull latest changes"
  exit 1
fi

# check if --verbose was passed
if [ "$2" = "--verbose" ]; then
  export verbose=true
  printfe "%s\n" "yellow" "Verbose mode enabled"
else
  export verbose=false
fi

####################################################################################################
# Update symlinks
####################################################################################################

printfe "%s\n" "cyan" "Updating symlinks..."
check_or_make_symlink ~/.zshrc ~/dotfiles/zshrc
check_or_make_symlink ~/.config/Code/User/settings.json ~/dotfiles/vscode/settings.json
check_or_make_symlink ~/.config/starship.toml ~/dotfiles/config/starship.toml

if [[ "$OSTYPE" == "darwin"* ]]; then
  check_or_make_symlink ~/.gitconfig ~/dotfiles/config/gitconfig.macos
else
  check_or_make_symlink ~/.gitconfig ~/dotfiles/config/gitconfig.linux
fi

check_or_make_symlink ~/.ssh/config ~/dotfiles/config/ssh/config
check_or_make_symlink ~/.ssh/config.d ~/dotfiles/config/ssh/config.d
check_or_make_symlink ~/.wezterm.lua ~/dotfiles/config/wezterm.lua

####################################################################################################
# Update system packages
####################################################################################################

printfe "%s\n" "cyan" "Updating system packages..."
if [[ "$OSTYPE" == "darwin"* ]]; then
  brew update
  brew upgrade
  brew cleanup
else
  sudo nala upgrade -y
  sudo nala autoremove -y --purge
fi

####################################################################################################
# Update packages
####################################################################################################

printfe "%s\n" "cyan" "Oh My Zsh update..."
source ~/dotfiles/bin/helpers/ohmyzsh.sh
ensure_ohmyzsh_installed

printfe "%s\n" "cyan" "Rust update..."
source ~/dotfiles/bin/helpers/rust.sh
ensure_rust_installed

printfe "%s\n" "cyan" "Ensuring APT repositories are added..."
source ~/dotfiles/bin/helpers/apt_packages.sh
ensure_repositories

printfe "%s\n" "cyan" "Ensuring APT packages are installed..."
ensure_apt_packages_installed

printfe "%s\n" "cyan" "Ensuring pipx packages are installed..."
source ~/dotfiles/bin/helpers/pipx_packages.sh
ensure_pipx_packages_installed

printfe "%s\n" "cyan" "Ensuring GNOME Extensions are installed..."
source ~/dotfiles/bin/helpers/gnome_extensions.sh
ensure_gnome_extensions_installed

printfe "%s\n" "cyan" "Ensuring Cargo packages are installed..."
source ~/dotfiles/bin/helpers/cargo_packages.sh
ensure_cargo_packages_installed

printfe "%s\n" "cyan" "Ensuring Flatpak remotes are added..."
source ~/dotfiles/bin/helpers/flatpak_packages.sh
ensure_remotes_added

printfe "%s\n" "cyan" "Ensuring Flatpak packages are installed..."
ensure_flatpak_packages_installed

printfe "%s\n" "cyan" "Ensuring VSCode extensions are installed..."
source ~/dotfiles/bin/helpers/vscode-extensions.sh
ensure_vscode_extensions_installed

####################################################################################################
# Update system settings
####################################################################################################

printfe "%s\n" "cyan" "Setting up keyboard shortcuts..."
source ~/dotfiles/bin/helpers/keyboard_shortcuts.sh
ensure_keyboard_shortcuts

printfe "%s\n" "cyan" "Ensuring fonts are installed..."
source ~/dotfiles/bin/helpers/fonts.sh
ensure_fonts_installed

printfe "%s\n" "cyan" "Setting wezterm as default terminal..."
if [ ! -f /usr/bin/wezterm ]; then
  printfe "%s\n" "red" "Wezterm is not installed"
  exit 1
fi

current_terminal=$(sudo update-alternatives --query x-terminal-emulator | grep '^Value:' | awk '{print $2}')

if [ "$current_terminal" != "/usr/bin/wezterm" ]; then
    printfe "%s\n" "yellow" "    - Setting wezterm as default terminal"
    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/wezterm 60
else
    printfe "%s\n" "green" "    - wezterm is already the default terminal"
fi

printfe "%s\n" "cyan" "Setting zsh as default shell..."
if [ "$SHELL" != "/usr/bin/zsh" ]; then
  printfe "%s\n" "yellow" "    - Setting zsh as default shell"
  chsh -s /usr/bin/zsh
else
  printfe "%s\n" "green" "    - zsh is already the default shell"
fi

printfe "%s\n" "green" "Update complete!"