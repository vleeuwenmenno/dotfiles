#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Constants
readonly NIXOS_RELEASE="24.05"
readonly GIT_REPO="https://git.mvl.sh/vleeuwenmenno/dotfiles.git"
readonly DOTFILES_DIR="${HOME}/dotfiles"
readonly SETUP_MARKER="${HOME}/.dotfiles-setup"

# Color constants
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${YELLOW}$1${NC}"
}

log_success() {
    echo -e "${GREEN}$1${NC}"
}

log_error() {
    echo -e "${RED}$1${NC}" >&2
}

die() {
    log_error "$1"
    exit 1
}

# Ensure we're running interactively
ensure_interactive() {
    # If stdin is not a terminal, reconnect stdin to /dev/tty
    if [ ! -t 0 ]; then
        exec < /dev/tty || die "Failed to connect to terminal. Please run the script directly instead of piping from curl"
    fi
}

confirm_symlink() {
    local link="$1"
    local msg="$2"
    if [ ! -L "$link" ]; then
        die "$msg"
    fi
}

backup_file() {
    local file="$1"
    local need_sudo="$2"

    if [ -f "$file" ]; then
        log_info "Backing up $file to $file.bak..."
        if [ "$need_sudo" = "true" ]; then
            sudo mv "$file" "$file.bak" || die "Failed to backup $file (sudo)"
        else
            mv "$file" "$file.bak" || die "Failed to backup $file"
        fi
    fi
}

check_prerequisites() {
    command -v git >/dev/null 2>&1 || die "Git is required but not installed"
    command -v sudo >/dev/null 2>&1 || die "Sudo is required but not installed"
}

validate_hostname() {
    local hostname="$1"
    if [[ -z "$hostname" || ! "$hostname" =~ ^[a-zA-Z0-9_-]+$ || ${#hostname} -gt 64 ]]; then
        return 1
    fi
    return 0
}

create_hardware_config() {
    local hostname="$1"
    log_info "Creating hardware configuration for $hostname..."

    local config_file="$DOTFILES_DIR/config/nixos/hardware/$hostname.nix"
    local template=$(cat << 'EOF'
    {
        config,
        lib,
        pkgs,
        modulesPath,
        ...
    }:
    {
        imports = [ /etc/nixos/hardware-configuration.nix ];
        networking.hostName = "%s";
    }
EOF
)

    printf "$template" "$hostname" > "$config_file" || \
        die "Failed to create hardware configuration"

    log_success "Hardware configuration created successfully."
    log_info "Consider adding additional hardware configuration to $config_file"

    # Ensure interactive input before system type selection
    ensure_interactive

    # System type selection
    local systemType
    while true; do
        log_info "Is this a server or workstation? (s/w)"
        read -r -p "(s/w): " systemType
        if [[ "$systemType" =~ ^[sw]$ ]]; then
            break
        fi
        log_error "Invalid input. Please enter 's' for server or 'w' for workstation."
    done

    local isServer="false"
    local isWorkstation="false"
    if [ "$systemType" = "s" ]; then
        isServer="true"
    else
        isWorkstation="true"
    fi

    # Update flake configurations
    update_nixos_flake "$hostname" "$isServer" "$isWorkstation" || \
        die "Failed to update NixOS flake configuration"
    
    update_home_manager_flake "$hostname" "$isServer" || \
        die "Failed to update Home Manager flake configuration"

    # Add new files to git
    git -C "$DOTFILES_DIR" add \
        "config/nixos/hardware/$hostname.nix" \
        "config/nixos/flake.nix" \
        "config/home-manager/flake.nix" || \
        die "Failed to add files to git"

    log_info "\nDon't forget to commit and push the changes to the dotfiles repo after testing."
    git -C "$DOTFILES_DIR" status
    echo
}

update_nixos_flake() {
    local hostname="$1"
    local isServer="$2"
    local isWorkstation="$3"
    local flake_file="$DOTFILES_DIR/config/nixos/flake.nix"
    
    # Determine which common module to use
    local common_module="./common/workstation.nix"
    if [ "$isServer" = "true" ]; then
        common_module="./common/server.nix"
    fi

    # Create new configuration entry
    local new_config="        \"$hostname\" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hardware/$hostname.nix
            $common_module
            ./configuration.nix
          ];
          specialArgs = {
            inherit pkgs-unstable;
            isWorkstation = $isWorkstation;
            isServer = $isServer;
          };
        };
        "

    # Create temporary file
    local temp_file=$(mktemp)
    
    # Find the line number where nixosConfigurations = { appears
    local config_line=$(grep -n "nixosConfigurations = {" "$flake_file" | cut -d: -f1)
    
    if [ -z "$config_line" ]; then
        rm "$temp_file"
        die "Could not find nixosConfigurations in flake.nix"
    fi

    # Copy the file up to the line after nixosConfigurations = {
    head -n "$config_line" "$flake_file" > "$temp_file"
    
    # Add the new configuration
    echo "$new_config" >> "$temp_file"
    
    # Add the rest of the file starting from the line after nixosConfigurations = {
    tail -n +"$((config_line + 1))" "$flake_file" >> "$temp_file"

    # Validate the new file
    if ! nix-shell -p nixfmt --run "nixfmt $temp_file"; then
        rm "$temp_file"
        return 1
    fi

    # Replace original file
    mv "$temp_file" "$flake_file" || return 1
    log_success "NixOS Flake configuration added successfully."
}

update_home_manager_flake() {
    local hostname="$1"
    local isServer="$2"
    local flake_file="$DOTFILES_DIR/config/home-manager/flake.nix"
    
    # Create new configuration entry
    local new_config="        \"$hostname\" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit pkgs pkgs-unstable;
            isServer = $isServer;
            hostname = \"$hostname\";
          };
        };
        "

    # Create temporary file
    local temp_file=$(mktemp)
    
    # Find the line number where homeConfigurations = { appears
    local config_line=$(grep -n "homeConfigurations = {" "$flake_file" | cut -d: -f1)
    
    if [ -z "$config_line" ]; then
        rm "$temp_file"
        die "Could not find homeConfigurations in flake.nix"
    fi

    # Copy the file up to the line after homeConfigurations = {
    head -n "$config_line" "$flake_file" > "$temp_file"
    
    # Add the new configuration
    echo "$new_config" >> "$temp_file"
    
    # Add the rest of the file starting from the line after homeConfigurations = {
    tail -n +"$((config_line + 1))" "$flake_file" >> "$temp_file"

    # Validate the new file
    if ! nix-shell -p nixfmt --run "nixfmt $temp_file"; then
        rm "$temp_file"
        return 1
    fi

    # Replace original file
    mv "$temp_file" "$flake_file" || return 1
    log_success "Home Manager Flake configuration added successfully."
}

install_nix() {
    if command -v nixos-version >/dev/null 2>&1; then
        log_success "Detected NixOS, skipping Nix setup."
        return 0
    fi

    log_info "NixOS not detected, installing Nix..."
    if ! sh <(curl -L https://nixos.org/nix/install) --daemon; then
        die "Failed to install Nix"
    fi
}

setup_symlinks() {
    log_info "Setting up symlinks..."

    # Backup and create symlinks for user files
    backup_file "$HOME/.bashrc"
    backup_file "$HOME/.profile"

    if [ -d "$HOME/.config/home-manager" ]; then
        log_info "Backing up ~/.config/home-manager to ~/.config/home-manager.bak..."
        mv "$HOME/.config/home-manager" "$HOME/.config/home-manager.bak" || \
            die "Failed to backup home-manager config"
    fi

    log_info "Linking ~/.config/home-manager to $DOTFILES_DIR/config/home-manager..."
    ln -s "$DOTFILES_DIR/config/home-manager" "$HOME/.config/home-manager" || \
        die "Failed to create home-manager symlink"

    # Handle NixOS configuration with proper sudo permissions
    if [ -d "/etc/nixos" ]; then
        if [ -f "/etc/nixos/configuration.nix" ]; then
            backup_file "/etc/nixos/configuration.nix" true
        fi

        log_info "Linking /etc/nixos/configuration.nix to $DOTFILES_DIR/config/nixos/configuration.nix..."
        sudo ln -s "$DOTFILES_DIR/config/nixos/configuration.nix" "/etc/nixos/configuration.nix" || \
            die "Failed to create nixos configuration symlink"
    fi

    # Verify symlinks
    confirm_symlink "$HOME/.config/home-manager" "Failed to set up home-manager symlink"
    confirm_symlink "/etc/nixos/configuration.nix" "Failed to set up nixos configuration symlink"

    log_success "Symlinks set up successfully."
}

install_home_manager() {
    if command -v home-manager >/dev/null 2>&1; then
        log_success "Home Manager already installed. Skipping..."
        return 0
    fi

    log_info "Installing Home Manager..."
    
    sudo nix-channel --add "https://github.com/nix-community/home-manager/archive/release-$NIXOS_RELEASE.tar.gz" home-manager || \
        die "Failed to add home-manager channel"
    
    sudo nix-channel --update || die "Failed to update channels"
    
    sudo nix-shell '<home-manager>' -A install || die "Failed to install home-manager (sudo)"
    nix-shell '<home-manager>' -A install || die "Failed to install home-manager"
}

prepare_hostname() {
    local hostname_file="$HOME/.hostname"
    local hostname

    if [ -f "$hostname_file" ]; then
        hostname=$(cat "$hostname_file")
        log_success "Hostname already found in $hostname_file. Using $hostname."

        if [ ! -f "$DOTFILES_DIR/config/nixos/hardware/$hostname.nix" ]; then
            die "No hardware configuration found for $hostname. Please create a hardware configuration for this machine."
        fi

        log_success "Hardware configuration found for $hostname. Continuing setup..."
        return
    fi

    # Ensure interactive input before hostname prompt
    ensure_interactive

    while true; do
        log_info "Enter the hostname for this machine:"
        read -r hostname
        if validate_hostname "$hostname"; then
            break
        fi
        log_error "Invalid hostname. Please enter a valid hostname:"
    done

    if [ ! -f "$DOTFILES_DIR/config/nixos/hardware/$hostname.nix" ]; then
        log_info "No hardware configuration found for $hostname."
        create_hardware_config "$hostname"
    else
        log_success "Hardware configuration found for $hostname. Continuing setup..."
    fi

    echo "$hostname" > "$hostname_file" || die "Failed to save hostname"
    log_success "Hostname set successfully."
}

main() {
    # Check if setup has already been run
    if [ -f "$SETUP_MARKER" ]; then
        log_info "Setup has already been run, exiting..."
        exit 0
    fi

    # Check prerequisites
    check_prerequisites

    # Clone dotfiles if needed
    if [ ! -d "$DOTFILES_DIR" ]; then
        log_info "Cloning dotfiles repo..."
        git clone "$GIT_REPO" "$DOTFILES_DIR" || die "Failed to clone dotfiles repository"
    fi

    # Run setup steps
    prepare_hostname
    setup_symlinks
    install_nix
    install_home_manager

    # Get hostname
    local hostname
    hostname=$(cat "$HOME/.hostname") || die "Failed to read hostname"

    # Rebuild NixOS
    cd "$DOTFILES_DIR/config/nixos" || die "Failed to change to nixos config directory"
    sudo nixos-rebuild switch --flake ".#$hostname" --impure || \
        die "Failed to rebuild NixOS"

    # Rebuild Home Manager
    cd "$DOTFILES_DIR/config/home-manager" || die "Failed to change to home-manager config directory"
    NIXPKGS_ALLOW_UNFREE=1 home-manager switch --flake ".#$hostname" --impure || \
        die "Failed to rebuild Home Manager"

    # Create setup marker
    touch "$SETUP_MARKER" || die "Failed to create setup marker"

    # Final success message
    log_success "\nSetup complete. Please logout / restart to continue with 'dotf update'.\n"
    log_error "\n!!! Please logout / restart to continue !!!"
    log_error "~~~   Proceed by running 'dotf update'  ~~~\n"
}

main "$@"
