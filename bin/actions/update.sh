#!/usr/bin/env bash

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

ensure_symlink() {
  local source
  local target

  # Fetch target from YAML
  target=$(shyaml get-value "config.symlinks.$1.target" < "$HOME/dotfiles/config/config.yaml" 2>/dev/null)
  
  # Fetch source from YAML based on OS
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Check for WSL2
    if [[ $(uname -a) == *"microsoft-standard-WSL2"* ]]; then
      source=$(shyaml get-value "config.symlinks.$1.sources.wsl" < "$HOME/dotfiles/config/config.yaml" 2>/dev/null)
    else
      source=$(shyaml get-value "config.symlinks.$1.sources.linux" < "$HOME/dotfiles/config/config.yaml" 2>/dev/null)
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    source=$(shyaml get-value "config.symlinks.$1.sources.macos" < "$HOME/dotfiles/config/config.yaml" 2>/dev/null)
  fi

  # Fall back to generic source if OS-specific source is empty
  if [ -z "$source" ]; then
    source=$(shyaml get-value "config.symlinks.$1.source" < "$HOME/dotfiles/config/config.yaml" 2>/dev/null)
  fi

  # Attempt to use the hostname of the machine if source is still empty
  if [ -z "$source" ]; then
    source=$(shyaml get-value "config.symlinks.$1.sources.$(hostname)" < "$HOME/dotfiles/config/config.yaml" 2>/dev/null)
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
    # Resolve the target if it is a symlink
    resolved_target=$(readlink -f "$target")
    
    # If readlink fails, fall back to the original target
    if [ -z "$resolved_target" ]; then
      resolved_target="$target"
    fi

    current_chmod=$(stat -c %a "$resolved_target" 2>/dev/null)
    if [ "$current_chmod" != "$desired_chmod" ]; then
      printfe "%s\n" "yellow" "    - Changing chmod of $resolved_target to $desired_chmod"
      chmod "$desired_chmod" "$resolved_target"
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

  for symlink in "${symlinks[@]}"; do
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
    if [ -x "$(command -v nixos-version)" ]; then
      cd $HOME/dotfiles/config/nixos && sudo nixos-rebuild switch --flake .#$DOTF_HOSTNAME --impure

      # Exit if this failed
      if [ $? -ne 0 ]; then
        exit $?
      fi
      return
    fi
    
    sudo nala upgrade -y
    sudo nala autoremove -y --purge
  fi
}

####################################################################################################
# Update packages
####################################################################################################

cargopkgs() {  
  printfe "%s\n" "cyan" "Ensuring Cargo packages are installed..."
  source $HOME/dotfiles/bin/helpers/cargo_packages.sh
  ensure_cargo_packages_installed
}

pipxpkgs() {
  if [ ! -x "$(command -v pipx)" ]; then
    printfe "%s\n" "yellow" "pipx is not available, skipping pipx packages."
    return
  fi

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
  if [ ! -x "$(command -v flatpak)" ]; then
    printfe "%s\n" "yellow" "Flatpak is not available, skipping Flatpak."
    return
  fi

  if is_wsl; then
    printfe "%s\n" "yellow" "Running in WSL, skipping Flatpak."
    return
  fi

  printfe "%s\n" "cyan" "Ensuring Flatpak packages are installed..."
  source $HOME/dotfiles/bin/helpers/flatpak_packages.sh
  ensure_flatpak_packages_installed
}

tailscalecmd() {
  if is_wsl; then
    printfe "%s\n" "yellow" "Running in WSL, skipping Tailscale."
    return
  fi

  printfe "%s\n" "cyan" "Ensuring Tailscale is installed..."
  source $HOME/dotfiles/bin/helpers/tailscale.sh
  ensure_tailscale_installed
}

####################################################################################################
# Update system settings
####################################################################################################

fonts() {
  if is_wsl; then
    printfe "%s\n" "yellow" "Running in WSL, skipping fonts."
    return
  fi

  printfe "%s\n" "cyan" "Ensuring fonts are installed..."
  source $HOME/dotfiles/bin/helpers/fonts.sh
  ensure_fonts_installed
}

git_repos() {
  ####################################################################################################
  # Ensure git repos
  ####################################################################################################

  printfe "%s\n" "cyan" "Ensuring git repos..."
  source $HOME/dotfiles/bin/helpers/git.sh
  ensure_git_repos
}

homemanager() {
  cd $HOME/dotfiles/config/home-manager && NIXPKGS_ALLOW_UNFREE=1 home-manager switch -b backup --flake .#$DOTF_HOSTNAME
}

ensure_homemanager_installed() {
  if [ ! -x "$(command -v home-manager)" ]; then
    printfe "%s\n" "yellow" "Home Manager is not installed, installing it..."
    nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
    nix-channel --update
    nix-shell '<home-manager>' -A install

    printfe "%s\n" "yellow" "Home Manager installed, please run the script again."
    exit 1
  fi
}

####################################################################################################
# Parse arguments
####################################################################################################

# Multiple options can be passed to the script, for example:
# ./update.sh --git --symlinks --packages
# If no options are passed, the script will run all functions

# Shift the first argument since this is the script name
shift

if [ "$#" -eq 0 ]; then
  printfe "%s\n" "yellow" "No options passed, running full update..."

  ensure_homemanager_installed
  symlinks
  sys_packages
  homemanager
  cargopkgs
  pipxpkgs
  git_repos
  flatpakpkgs
  tailscalecmd
  dotf secrets encrypt
else
  for arg in "$@"; do
    case $arg in
    --nixos)
      sys_packages
      ;;
    --home-manager)
      homemanager
      ;;
    --nix)
      sys_packages
      homemanager
      ;;
    --git)
      git_repos
      ;;
    --symlinks)
      symlinks
      ;;
    --packages)
      sys_packages
      cargopkgs
      pipxpkgs
      flatpakpkgs
      tailscalecmd
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
    --tailscale)
      tailscalecmd
      ;;
    *)
      printfe "%s\n" "red" "Unknown option: $arg"
      ;;
    esac
  done
fi

echo ""
printfe "%s\n" "blue" "Done!"
