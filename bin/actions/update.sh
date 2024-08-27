#!/usr/bin/env zsh

source $HOME/dotfiles/bin/helpers/functions.sh

# check if --verbose was passed
if [ "$2" = "--verbose" ]; then
  export verbose=true
  printfe "%s\n" "yellow" "Verbose mode enabled"
else
  export verbose=false
fi

# Check if we have shyaml since that's required for the script to function
if [ ! -x "$(command -v shyaml)" ]; then
  printfe "%s\n" "red" "shyaml is not installed, installing it..."
  pipx install shyaml
fi

pull_dotfiles() {
  ####################################################################################################
  # Pull latest dotfiles
  ####################################################################################################

  printfe "%s\n" "cyan" "Pulling latest changes..."

  result=$(git -C $HOME/dotfiles pull --ff-only)

  if [ $? -ne 0 ]; then
    printfe "%s\n" "red" "    - Failed to pull latest changes"
    printfe "%s\n" "red" "      Result: $result"
    exit 1
  fi

  # In case it failed to pull due to conflicts, stop and notify the user
  if [[ $result == *"CONFLICT"* ]]; then
    printfe "%s\n" "red" "   - Failed to pull latest changes"
    printfe "%s\n" "red" "     Result: $result"
    exit 1
  fi

  if [ $? -ne 0 ]; then
    printfe "%s\n" "red" "Failed to pull latest changes"
    exit 1
  fi
}

groups() {
  ####################################################################################################
  # Ensure user groups
  ####################################################################################################

  printfe "%s\n" "cyan" "Ensuring user groups..."
  source $HOME/dotfiles/bin/helpers/user_groups.sh
  ensure_user_groups
}

ensure_symlink() {
  source=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-values config.symlinks.$1.source) &>/dev/null
  target=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.symlinks.$1.target) &>/dev/null

  # Based on the OS_TYPE, get the correct source
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    source=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.symlinks.$1.sources.linux)   &>/dev/null
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    source=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.symlinks.$1.sources.macos) &>/dev/null
  fi

  # Try adding a default source if the OS_TYPE specific source is empty
  if [ -z "$source" ]; then
    source=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.symlinks.$1.source) &>/dev/null
  fi

  # If this is still empty, last attempt, let's try use the hostname of the machine
  if [ -z "$source" ]; then
    source=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.symlinks.$1.sources.$(hostname)) &>/dev/null
  fi

  # If this is still empty, we can't continue and should throw up an error
  if [ -z "$source" ]; then
    printfe "%s\n" "red" "    - No valid source defined for $1"
    return
  fi
  
  check_or_make_symlink $source $target

  # Let's check if there was a chmod defined for the symlink
  chmod=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.symlinks.$1.chmod 2>/dev/null)

  if [ -n "$chmod" ]; then
    # Let's see if the current target has the correct chmod
    current_chmod=$(stat -c %a $target)
    if [ "$current_chmod" != "$chmod" ]; then
      printfe "%s" "yellow" "    - Changing chmod of $target to $chmod"
      # Replace ~ with $HOME in target
      target=$(echo $target | sed "s|~|$HOME|g")      
      chmod $chmod $target
    else
      return
    fi
  fi
}

symlinks() {
  ####################################################################################################
  # Update symlinks
  ####################################################################################################

  # Load symlinks from config file
  symlinks=($(cat $HOME/dotfiles/config/config.yaml | shyaml keys config.symlinks))
  printfe "%s\n" "cyan" "Updating symlinks..."

  for symlink in $symlinks; do
    ensure_symlink $symlink
  done  
}

sys_packages() {
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
}

####################################################################################################
# Update packages
####################################################################################################

cargopkgs() {
  printfe "%s\n" "cyan" "Rust update..."
  source $HOME/dotfiles/bin/helpers/rust.sh
  ensure_rust_installed 
  
  printfe "%s\n" "cyan" "Ensuring Cargo packages are installed..."
  source $HOME/dotfiles/bin/helpers/cargo_packages.sh
  ensure_cargo_packages_installed
}

aptpkgs() {
  printfe "%s\n" "cyan" "Ensuring APT repositories are added..."
  source $HOME/dotfiles/bin/helpers/apt_packages.sh
  ensure_repositories

  printfe "%s\n" "cyan" "Ensuring APT packages are installed..."
  ensure_apt_packages_installed
}

pipxpkgs() {
  printfe "%s\n" "cyan" "Ensuring pyenv is installed..."
  if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
  else
    printfe "%s\n" "green" "    - pyenv is already installed"
  fi

  printfe "%s\n" "cyan" "Ensuring pipx packages are installed..."
  source $HOME/dotfiles/bin/helpers/pipx_packages.sh
  ensure_pipx_packages_installed
}

flatpakpkgs() {
  printfe "%s\n" "cyan" "Ensuring Flatpak remotes are added..."
  source $HOME/dotfiles/bin/helpers/flatpak_packages.sh
  ensure_remotes_added

  printfe "%s\n" "cyan" "Ensuring Flatpak packages are installed..."
  ensure_flatpak_packages_installed
}

dockercmd() {
  printfe "%s\n" "cyan" "Ensuring Docker is installed..."
  source $HOME/dotfiles/bin/helpers/docker.sh
  ensure_docker_installed
}

tailscalecmd() {
  printfe "%s\n" "cyan" "Ensuring Tailscale is installed..."
  source $HOME/dotfiles/bin/helpers/tailscale.sh
  ensure_tailscale_installed
}

extensions() {
  printfe "%s\n" "cyan" "Ensuring Oh My Zsh is installed..."
  source $HOME/dotfiles/bin/helpers/ohmyzsh.sh
  ensure_ohmyzsh_installed

  printfe "%s\n" "cyan" "Ensuring GNOME Extensions are installed..."
  source $HOME/dotfiles/bin/helpers/gnome_extensions.sh
  ensure_gnome_extensions_installed

  printfe "%s\n" "cyan" "Ensuring VSCode extensions are installed..."
  source $HOME/dotfiles/bin/helpers/vscode-extensions.sh
  ensure_vscode_extensions_installed
}

####################################################################################################
# Update system settings
####################################################################################################

keyboard() {
  printfe "%s\n" "cyan" "Setting up keyboard shortcuts..."
  source $HOME/dotfiles/bin/helpers/keyboard_shortcuts.sh
  ensure_keyboard_shortcuts
}

fonts() {
  printfe "%s\n" "cyan" "Ensuring fonts are installed..."
  source $HOME/dotfiles/bin/helpers/fonts.sh
  ensure_fonts_installed
}

default_terminal() {
  printfe "%s\n" "cyan" "Setting alacritty as default terminal..."
  # Check if alacritty is installed
  if [ -x "$(command -v alacritty)" ]; then
    current_terminal=$(sudo update-alternatives --query x-terminal-emulator | grep '^Value:' | awk '{print $2}')

    if [ "$current_terminal" != $(which alacritty) ]; then
      printfe "%s\n" "yellow" "    - Setting alacritty as default terminal"
      sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $(which alacritty) 80
    else
      printfe "%s\n" "green" "    - alacritty is already the default terminal"
    fi
  else
    printfe "%s\n" "red" "    - alacritty is not installed"
  fi
}

default_shell() {
  printfe "%s\n" "cyan" "Setting zsh as default shell..."
  if [ "$SHELL" != "/usr/bin/zsh" ]; then
    printfe "%s\n" "yellow" "    - Setting zsh as default shell"
    chsh -s /usr/bin/zsh
  else
    printfe "%s\n" "green" "    - zsh is already the default shell"
  fi
}

####################################################################################################
# Parse arguments
####################################################################################################

# Multiple options can be passed to the script, for example:
# ./update.sh --verbose --groups --symlinks --packages --keyboard --fonts --default-terminal --default-shell
# If no options are passed, the script will run all functions

# Shift the first argument since this is the script name
shift

if [ "$#" -eq 0 ]; then
  printfe "%s\n" "yellow" "No options passed, running full update..."

  pull_dotfiles
  groups
  symlinks
  sys_packages
  aptpkgs
  cargopkgs
  pipxpkgs
  flatpakpkgs
  dockercmd
  tailscalecmd
  extensions
  keyboard
  fonts
  default_terminal
  default_shell
else
  for arg in "$@"; do
    case $arg in
    --pull)
      pull_dotfiles
      ;;
    --groups)
      groups
      ;;
    --symlinks)
      symlinks
      ;;
    --packages)
      sys_packages
      cargopkgs
      aptpkgs
      pipxpkgs
      flatpakpkgs
      dockercmd
      tailscalecmd
      ;;
    --apt)
      aptpkgs
      ;;
    --pipx)
      pipxpkgs
      ;;
    --cargo)
      cargopkgs
      ;;
    --flatpak)
      flatpakpkgs
      ;;
    --docker)
      dockercmd
      ;;
    --tailscale)
      tailscalecmd
      ;;
    --extensions)
      extensions
      ;;
    --keyboard)
      keyboard
      ;;
    --fonts)
      fonts
      ;;
    --default-terminal)
      default_terminal
      ;;
    --default-shell)
      default_shell
      ;;
    *)
      printfe "%s\n" "red" "Unknown option: $arg"
      ;;
    esac
  done
fi

echo ""
printfe "%s\n" "blue" "Done!"
