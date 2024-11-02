#!/usr/bin/env bash

NIXOS_RELEASE=24.05

# Check if $HOME/.dotfiles-setup exists, if so exit because setup has already been run
if [ -f $HOME/.dotfiles-setup ]; then
    echo "Setup has already been run, exiting..."
    exit 0
fi

# Check if nixos-version is available
ensure_nixos() {
    if [ -x "$(command -v nixos-version)" ]; then
        tput setaf 2
        echo "Detected NixOS, skipping Nix setup."
        tput sgr0
        return
    else 
        tput setaf 3
        echo "NixOS not detected, installing Nix..."
        tput sgr0
        sh <(curl -L https://nixos.org/nix/install) --daemon
    fi
}

setup_symlinks() {
    tput setaf 3
    echo "Setting up symlinks..."
    tput sgr0

    # Link .bashrc
    rm -rf $HOME/.bashrc
    ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc

    # Link proper home-manager configs
    rm -rf ~/.config/home-manager
    ln -s $HOME/dotfiles/config/home-manager ~/.config/home-manager

    # Link proper nixos configs
    sudo rm -rf /etc/nixos/configuration.nix
    sudo ln -s $HOME/dotfiles/config/nixos/configuration.nix /etc/nixos/configuration.nix
}

install_home_manager() {
    tput setaf 3
    echo "Installing Home Manager..."
    tput sgr0

    sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-$NIXOS_RELEASE.tar.gz home-manager
    sudo nix-channel --update
    sudo nix-shell '<home-manager>' -A install
    nix-shell '<home-manager>' -A install
}

prepare_hostname() {
    # Ask the user what hostname this machine should have
    tput setaf 3
    echo "Enter the hostname for this machine:"
    tput sgr0
    read hostname

    # Validate hostname to ensure it's not empty, contains only alphanumeric characters, and is less than 64 characters
    while [[ -z $hostname || ! $hostname =~ ^[a-zA-Z0-9_-]+$ || ${#hostname} -gt 64 ]]; do
        echo "Invalid hostname. Please enter a valid hostname:"
        read hostname
    done

    # Check if config/nixos/hardware/ contains config/nixos/hardware/$hostname.nix
    if [ ! -f $HOME/dotfiles/config/nixos/hardware/$hostname.nix ]; then
        echo "No hardware configuration found for $hostname. Please create a hardware configuration for this machine."
        exit 1
    fi

    tput setaf 2
    echo "Hardware configuration found for $hostname. Continuing setup..."
    tput sgr0

    # Set the hostname by dumping it into $HOME/.hostname
    touch $HOME/.hostname
    echo $hostname > $HOME/.hostname
}

prepare_hostname
ensure_nixos
install_home_manager
setup_symlinks

# Rebuild NixOS
sudo nixos-rebuild switch

# Rebuild Home Manager
cd $HOME/dotfiles/config/home-manager && NIXPKGS_ALLOW_UNFREE=1 home-manager switch

touch $HOME/.dotfiles-setup

# Print this in RED
tput setaf 1

echo "!!! Ensure the correct UUID is set for the boot device under your hardware configuration before rebooting !!!"
echo "!!! Afterwards logout / restart to continue with 'dotf update' !!!"

# Reset color
tput sgr0
