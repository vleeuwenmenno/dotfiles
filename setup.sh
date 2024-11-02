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

        if [ $? -ne 0 ]; then
            tput setaf 1
            echo "Failed to install Nix. Exiting..."
            tput sgr0
            exit 1
        fi
    fi
}

setup_symlinks() {
    tput setaf 3
    echo "Setting up symlinks..."
    tput sgr0

    # Link .bashrc
    if [ -f $HOME/.bashrc ]; then
        mv $HOME/.bashrc $HOME/.bashrc.bak
    fi
    ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc

    # Link proper home-manager configs
    if [ -d ~/.config/home-manager ]; then
        mv ~/.config/home-manager ~/.config/home-manager.bak
    fi
    ln -s $HOME/dotfiles/config/home-manager ~/.config/home-manager

    # Link proper nixos configs
    if [ -d /etc/nixos ]; then
        sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
    fi
    sudo ln -s $HOME/dotfiles/config/nixos/configuration.nix /etc/nixos/configuration.nix

    # Confirm paths are now proper symlinks
    if [ -L $HOME/.bashrc ] && [ -L ~/.config/home-manager ] && [ -L /etc/nixos/configuration.nix ]; then
        tput setaf 2
        echo "Symlinks set up successfully."
        tput sgr0
    else
        tput setaf 1
        echo "Failed to set up symlinks. Exiting..."
        tput sgr0
        exit 1
    fi
}

install_home_manager() {
    tput setaf 3
    echo "Installing Home Manager..."
    tput sgr0

    sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-$NIXOS_RELEASE.tar.gz home-manager
    sudo nix-channel --update
    sudo nix-shell '<home-manager>' -A install
    nix-shell '<home-manager>' -A install

    if [ $? -ne 0 ]; then
        tput setaf 1
        echo "Failed to install Home Manager. Exiting..."
        tput sgr0
        exit 1
    fi
}

prepare_hostname() {
    # Check if $HOME/.hostname exists, if skip hostname setup
    if [ -f $HOME/.hostname ]; then
        hostname=$(cat $HOME/.hostname)
        tput setaf 2
        echo "Hostname already found in $HOME/.hostname. Using $hostname."
        tput sgr0

        # Check if config/nixos/hardware/ contains config/nixos/hardware/$hostname.nix
        if [ ! -f $HOME/dotfiles/config/nixos/hardware/$hostname.nix ]; then
            echo "No hardware configuration found for $hostname. Please create a hardware configuration for this machine."
            exit 1
        fi

        tput setaf 2
        echo "Hardware configuration found for $hostname. Continuing setup..."
        tput sgr0
        return
    fi

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

    # Confirm we saved the hostname to $HOME/.hostname
    if [ -f $HOME/.hostname ] && [ $(cat $HOME/.hostname) == $hostname ]; then
        tput setaf 2
        echo "Hostname set successfully."
        tput sgr0
    else
        tput setaf 1
        echo "Failed to set hostname. Exiting..."
        tput sgr0
        exit 1
    fi
}

prepare_hostname
ensure_nixos
install_home_manager
setup_symlinks

# Rebuild NixOS
cd $HOME/dotfiles/config/nixos && sudo nixos-rebuild switch --flake .#$DOTF_HOSTNAME --impure
if [ $? -ne 0 ]; then
    tput setaf 1
    echo "Failed to rebuild NixOS. Exiting..."
    tput sgr0
    exit 1
fi

# Rebuild Home Manager
cd $HOME/dotfiles/config/home-manager && NIXPKGS_ALLOW_UNFREE=1 home-manager switch
if [ $? -ne 0 ]; then
    tput setaf 1
    echo "Failed to rebuild Home Manager. Exiting..."
    tput sgr0
    exit 1
fi

tput setaf 2
echo
echo "Setup complete. Please logout / restart to continue with 'dotf update'."
echo
tput sgr0

touch $HOME/.dotfiles-setup

tput setaf 1
echo
echo "!!! Ensure the correct UUID is set for the boot device under your hardware configuration before rebooting !!!"
echo "!!! Afterwards logout / restart to continue with 'dotf update' !!!"
echo
tput sgr0
