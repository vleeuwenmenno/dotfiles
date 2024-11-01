#!/usr/bin/env bash

# Check if nixos-version is available
if [ -x "$(command -v nixos-version)" ]; then
    echo "Detected NixOS, skipping Nix setup."
    return
else 
    echo "NixOS not detected, installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
fi

# Check if home-manager is available
if [ -x "$(command -v home-manager)" ]; then
    echo "Detected Home Manager, did you setup everything already!?"
    echo "You should only run ./setup.sh once, re-running this could do damage."
    exit 0
fi

# Link .bashrc
rm -rf $HOME/.bashrc
ln -s $HOME/dotfiles/.bashrc $HOME/.bashrc

# Install home-manager
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
sudo nix-channel --update
sudo nix-shell '<home-manager>' -A install
nix-shell '<home-manager>' -A install

# Link proper home-manager configs
rm -rf ~/.config/home-manager
ln -s $HOME/dotfiles/config/home-manager ~/.config/home-manager

# Link proper nixos configs
sudo ln -s $HOME/dotfiles/config/nixos/configuration.nix /etc/nixos/configuration.nix

# Rebuild NixOS
sudo nixos-rebuild switch

# Rebuild Home Manager
cd $HOME/dotfiles/config/home-manager && NIXPKGS_ALLOW_UNFREE=1 home-manager switch

echo "##############################################################"
echo "#                                                            #"
echo "# !!!    LOGOUT & LOGIN OR RESTART BEFORE YOU CONTINUE   !!! #"
echo "# !!!              Continue with 'dotf update'           !!! #"
echo "#                                                            #"
echo "##############################################################"
