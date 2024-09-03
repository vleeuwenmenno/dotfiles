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

groups() {
  ####################################################################################################
  # Ensure user groups
  ####################################################################################################

  printfe "%s\n" "cyan" "Ensuring user groups..."
  source $HOME/dotfiles/bin/helpers/user_groups.sh
  ensure_user_groups
}

ensure_symlink() {
  local source
  local target

  # Fetch target from YAML
  target=$(shyaml get-value "config.symlinks.$1.target" < "$HOME/dotfiles/config/config.yaml") 2>/dev/null
  
  # Fetch source from YAML based on OS
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    source=$(shyaml get-value "config.symlinks.$1.sources.linux" < "$HOME/dotfiles/config/config.yaml") 2>/dev/null
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    source=$(shyaml get-value "config.symlinks.$1.sources.macos" < "$HOME/dotfiles/config/config.yaml") 2>/dev/null
  fi

  # Fall back to generic source if OS-specific source is empty
  if [ -z "$source" ]; then
    source=$(shyaml get-value "config.symlinks.$1.source" < "$HOME/dotfiles/config/config.yaml") 2>/dev/null
  fi

  # Attempt to use the hostname of the machine if source is still empty
  if [ -z "$source" ]; then
    source=$(shyaml get-value "config.symlinks.$1.sources.$(hostname)" < "$HOME/dotfiles/config/config.yaml") 2>/dev/null
  fi

  # Error out if source is still empty
  if [ -z "$source" ]; then
    printfe "%s\n" "red" "    - No valid source defined for $1"
    return
  fi

  # Expand ~ with $HOME
  source="${source/#\~/$HOME}"
  target="${target/#\~/$HOME}"

  # Call the function to check or make the symlink
  check_or_make_symlink "$source" "$target"

  # Check if there is a chmod defined for the target file
  desired_chmod=$(shyaml get-value "config.symlinks.$1.chmod" < "$HOME/dotfiles/config/config.yaml" 2>/dev/null)

  if [ -n "$desired_chmod" ]; then
    # Check if the current source file has the correct chmod
    current_chmod=$(stat -c %a "$source") # Check permissions of source file, since that's what chmod affects.
    if [ "$current_chmod" != "$desired_chmod" ]; then
      printfe "%s\n" "yellow" "    - Changing chmod of $source to $desired_chmod"
      chmod "$desired_chmod" "$source"
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
  printfe "%s\n" "cyan" "Ensuring Flatpak packages are installed..."
  source $HOME/dotfiles/bin/helpers/flatpak_packages.sh
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

  if [ ! -f "$HOME/.local/share/nemo/actions/vscode.nemo_action" ]; then
    printfe "%s\n" "cyan" "Ensuring nemo open with VSCode extension is installed..."
    wget https://raw.githubusercontent.com/mhsattarian/nemo-open-in-vscode/master/vscode.nemo_action -O $HOME/.local/share/nemo/actions/vscode.nemo_action
  else
    printfe "%s\n" "green" "    - nemo open with VSCode extension is already installed"
  fi
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

terminal() {
  printfe "%s\n" "cyan" "Setting gnome-terminal as default terminal..."
  if [ -x "$(command -v gnome-terminal)" ]; then
    current_terminal=$(sudo update-alternatives --query x-terminal-emulator | grep '^Value:' | awk '{print $2}')

    if [ "$current_terminal" != $(which gnome-terminal) ]; then
      printfe "%s\n" "yellow" "    - Setting gnome-terminal as default terminal"
      sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator $(which gnome-terminal) 80
    else
      printfe "%s\n" "green" "    - gnome-terminal is already the default terminal"
    fi
  else
    printfe "%s\n" "red" "    - gnome-terminal is not installed"
  fi

  # Reset gnome-terminal settings
  printfe "%s\n" "cyan" "Resetting gnome-terminal settings..."
  dconf reset -f /org/gnome/terminal/

  # Set gnome-terminal settings from $HOME/dotfiles/config/gnome-terminal
  printfe "%s\n" "cyan" "Loading gnome-terminal settings..."
  dconf load /org/gnome/terminal/ < $HOME/dotfiles/config/gnome-terminal.dconf
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

git_repos() {
  ####################################################################################################
  # Ensure git repos
  ####################################################################################################

  printfe "%s\n" "cyan" "Ensuring git repos..."
  source $HOME/dotfiles/bin/helpers/git.sh
  ensure_git_repos
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

  git_repos
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
  terminal
  default_shell
else
  for arg in "$@"; do
    case $arg in
    --git)
      git_repos
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
    --terminal)
      terminal
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
