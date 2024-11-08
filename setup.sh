#!/usr/bin/env bash

NIXOS_RELEASE=24.05
GIT_REPO=https://git.mvl.sh/vleeuwenmenno/dotfiles.git

# Check if $HOME/.dotfiles-setup exists, if so exit because setup has already been run
if [ -f $HOME/.dotfiles-setup ]; then
    echo "Setup has already been run, exiting..."
    exit 0
fi

# Check if $HOME/dotfiles exists, if not clone the dotfiles repo
if [ ! -d $HOME/dotfiles ]; then
    tput setaf 3
    echo "Cloning dotfiles repo..."
    tput sgr0
    git clone $GIT_REPO $HOME/dotfiles
fi

create_hardware_config() {
    hostname=$1

    tput setaf 3
    echo "Creating hardware configuration for $hostname..."
    tput sgr0

    template="
    {
        config,
        lib,
        pkgs,
        modulesPath,
        ...
    }:
    {
        imports = [ /etc/nixos/hardware-configuration.nix ];
        networking.hostName = \"$hostname\";
    }"

    echo "$template" > $HOME/dotfiles/config/nixos/hardware/$hostname.nix

    if [ -f $HOME/dotfiles/config/nixos/hardware/$hostname.nix ]; then
        tput setaf 2
        echo "Hardware configuration created successfully."
        echo "Consider adding additional hardware configuration to ~/dotfiles/config/nixos/hardware/$hostname.nix."
        tput sgr0
    else
        tput setaf 1
        echo "Failed to create hardware configuration. Exiting..."
        tput sgr0
        exit 1
    fi

    # Ask if this is a server or workstation
    tput setaf 3
    echo "Is this a server or workstation? (s/w)"
    tput sgr0
    read type

    while [[ $type != "s" && $type != "w" ]]; do
        echo "Invalid input. Please enter 's' for server or 'w' for workstation:"
        read type
    done

    if [ $type == "s" ]; then
        isServer="true"
        isWorkstation="false"
    else
        isServer="false"
        isWorkstation="true"
    fi

    flakeConfiguration="

        "$hostname" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hardware/$hostname.nix
            ./common/server.nix
            ./configuration.nix
          ];
          specialArgs = {
            inherit pkgs-unstable;
            isWorkstation = $isWorkstation;
            isServer = $isServer;
          };
        };

    "

    # Insert flakeConfiguration into flake.nix at nixosConfigurations = { ... }
    sed -i "s/nixosConfigurations = {/nixosConfigurations = { $flakeConfiguration/g" $HOME/dotfiles/config/nixos/flake.nix

    # Validate flake.nix with nixfmt
    nix-shell -p nixfmt --run "nixfmt $HOME/dotfiles/config/nixos/flake.nix"

    if [ $? -ne 0 ]; then
        tput setaf 1
        echo "Something went wrong adding the flake configuration for NixOS."
        echo "Failed to validate flake.nix. Exiting..."
        tput sgr0
        exit 1
    fi

    tput setaf 2
    echo "NixOS Flake configuration added successfully."
    tput sgr0

    haFlakeConfiguration="

        "$hostname" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
          extraSpecialArgs = {
            inherit pkgs pkgs-unstable;
            isServer = $isServer;
            hostname = "$hostname";
          };
        };

    "

    # Insert haFlakeConfiguration into flake.nix of home-manager at homeConfigurations = {
    sed -i "s/homeConfigurations = {/homeConfigurations = { $haFlakeConfiguration/g" $HOME/dotfiles/config/home-manager/flake.nix

    # Validate flake.nix with nixfmt
    nix-shell -p nixfmt --run "nixfmt $HOME/dotfiles/config/home-manager/flake.nix"

    if [ $? -ne 0 ]; then
        tput setaf 1
        echo "Something went wrong adding the flake configuration for Home Manager."
        echo "Failed to validate flake.nix. Exiting..."
        tput sgr0
        exit 1
    fi

    tput setaf 2
    echo "Home Manager Flake configuration added successfully."
    tput sgr0


    # Add to git
    git add $HOME/dotfiles/config/nixos/hardware/$hostname.nix $HOME/dotfiles/config/nixos/flake.nix $HOME/dotfiles/config/home-manager/flake.nix

    tput setaf 3
    echo ""
    echo "Don't forget to commit and push the changes to the dotfiles repo after testing."
    tput sgr0

    git status
    echo ""
}

install_nix() {
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

clear_files() {
    tput setaf 3
    echo "Setting up symlinks..."
    tput sgr0

    # Link .bashrc
    if [ -f $HOME/.bashrc ]; then
        echo "Backing up $HOME/.bashrc to $HOME/.bashrc.bak..."
        mv $HOME/.bashrc $HOME/.bashrc.bak
    fi

    # Link proper home-manager configs
    if [ -d ~/.config/home-manager ]; then
        echo "Backing up ~/.config/home-manager to ~/.config/home-manager.bak..."
        mv ~/.config/home-manager ~/.config/home-manager.bak
    fi
    echo "Linking ~/.config/home-manager to $HOME/dotfiles/config/home-manager..."
    ln -s $HOME/dotfiles/config/home-manager ~/.config/home-manager

    # Link proper nixos configs
    if [ -d /etc/nixos ]; then
        echo "Backing up /etc/nixos/configuration.nix to /etc/nixos/configuration.nix.bak..."
        sudo mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
    fi
    echo "Linking /etc/nixos/configuration.nix to $HOME/dotfiles/config/nixos/configuration.nix..."
    sudo ln -s $HOME/dotfiles/config/nixos/configuration.nix /etc/nixos/configuration.nix

    # Confirm paths are now proper symlinks
    if [ -L ~/.config/home-manager ] && [ -L /etc/nixos/configuration.nix ]; then
        # Confirm .bashrc and .profile are no longer present to prevent conflicts in nixoos-rebuild/home-manager switch
        if [ ! -f $HOME/.bashrc ] && [ ! -f $HOME/.profile ]; then
            tput setaf 2
            echo "Symlinks set up successfully."
            tput sgr0
        else
            tput setaf 1
            echo "Failed to set up symlinks. Exiting..."
            tput sgr0
            exit 1
        fi
    else
        tput setaf 1
        echo "Failed to set up symlinks. Exiting..."
        tput sgr0
        exit 1
    fi
}

install_home_manager() {
    if [ -x "$(command -v home-manager)" ]; then
        tput setaf 2
        echo "Home Manager already installed. Skipping..."
        tput sgr0
        return
    fi

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
        echo "No hardware configuration found for $hostname."
        create_hardware_config $hostname
        return
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
clear_files
install_nix
install_home_manager

# Rebuild NixOS
cd $HOME/dotfiles/config/nixos && sudo nixos-rebuild switch --flake .#$hostname --impure
if [ $? -ne 0 ]; then
    tput setaf 1
    echo "Failed to rebuild NixOS. Exiting..."
    tput sgr0
    exit 1
fi

# Rebuild Home Manager
cd $HOME/dotfiles/config/home-manager && NIXPKGS_ALLOW_UNFREE=1 home-manager switch --flake .#$hostname --impure
if [ $? -ne 0 ]; then
    tput setaf 1
    echo "Failed to rebuild Home Manager. Exiting..."
    tput sgr0
    exit 1
fi

# Make .profile a symlink to .bashrc
if [ -f $HOME/.profile ]; then
    echo "Backup up $HOME/.profile to $HOME/.profile.bak..."
    mv $HOME/.profile $HOME/.profile.bak
fi

tput setaf 2
echo
echo "Setup complete. Please logout / restart to continue with 'dotf update'."
echo
tput sgr0

touch $HOME/.dotfiles-setup

tput setaf 1
echo
echo "!!! Please logout / restart to continue !!!"
echo "~~~   Proceed by running 'dotf update'  ~~~"
echo
tput sgr0
