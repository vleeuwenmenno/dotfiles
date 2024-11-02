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
        echo "Detected NixOS, skipping Nix setup."
        return
    else 
        echo "NixOS not detected, installing Nix..."
        sh <(curl -L https://nixos.org/nix/install) --daemon
    fi
}

setup_symlinks() {
    # Link .bashrc
    rm -rf $HOME/.bashrc
    ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc

    # Link proper home-manager configs
    rm -rf ~/.config/home-manager
    ln -s $HOME/dotfiles/config/home-manager ~/.config/home-manager

    # Link proper nixos configs
    sudo ln -s $HOME/dotfiles/config/nixos/configuration.nix /etc/nixos/configuration.nix
}

install_home_manager() {
    sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-$NIXOS_RELEASE.tar.gz home-manager
    sudo nix-channel --update
    sudo nix-shell '<home-manager>' -A install
    nix-shell '<home-manager>' -A install
}

prepare_hostname() {
    # Ask the user what hostname this machine should have
    echo "Enter the hostname for this machine:"
    read hostname

    # Validate hostname to ensure it's not empty, contains only alphanumeric characters, and is less than 64 characters
    while [[ -z $hostname || ! $hostname =~ ^[a-zA-Z0-9_-]+$ || ${#hostname} -gt 64 ]]; do
        echo "Invalid hostname. Please enter a valid hostname:"
        read hostname
    done

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

echo "##############################################################"
echo "#                                                            #"
echo "# !!!    LOGOUT & LOGIN OR RESTART BEFORE YOU CONTINUE   !!! #"
echo "# !!!              Continue with 'dotf update'           !!! #"
echo "#                                                            #"
echo "##############################################################"
