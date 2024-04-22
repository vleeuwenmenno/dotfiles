#!/bin/bash
DOTFILES_REPO="https://github.com/vleeuwenmenno/dotfiles.git"

help() {
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -i, --install     Run installation process"
    echo "   -c, --continue    Install home-manager and switch to dotfiles flake"
    echo "   -h, --help        Display this help message"
    echo
    exit 1
}

install_nix() {
    # Check if nix is installed (nix command is available)
    if command -v nix > /dev/null; then
        echo 'NIX is already installed.'
    else
        echo 'Installing NIX'
        sh <(curl -L https://nixos.org/nix/install) --daemon
    fi
}

hush_login() {
    # Check if distro is Ubuntu
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            return 1
        fi
    else
        return 1
    fi

    # If .hushlogin does not exist, create it
    if [ -f ~/.hushlogin ]; then
        echo 'Login message is already disabled.'
    else
        echo 'Disabling login message.'
        touch ~/.hushlogin
    fi
}

nix_experimental() {
    if command -v nix > /dev/null; then
        echo 'NIX is already installed.'
    else
        install_nix
    fi

    echo "Adding experimental-features to nix.conf..."
    grep -qxF 'experimental-features = nix-command flakes' /etc/nix/nix.conf || echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
}

nix_config_import() {
    # Check if nix configuration is already inserted
    if [ -f ~/.config/nix/nix.conf ]; then
        echo "Nix configuration is already inserted."
        exit 1
    else
        echo "Inserting nix configuration..."
        mkdir -p ~/.config/nix
        curl -s $NIX_CONFIG_URL -o ~/.config/nix/nix.conf
    fi
}

clone_dotfiles() {
    if [ -d ~/.dotfiles ]; then
        echo "Dotfiles already cloned."
    else
        echo "Cloning dotfiles..."
        git clone $DOTFILES_REPO ~/.dotfiles
    fi
}

home_manager_setup() {
    # Check if home-manager is installed
    if command -v home-manager > /dev/null; then
        echo "Home-manager is already installed."
    else
        echo "Installing home-manager..."
        nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
        nix-channel --update
        nix-shell '<home-manager>' -A install
    fi
}

switch_to_home_manager() {
    echo 'Running home-manager switch...'
    home-manager switch --flake ~/.dotfiles
}

continue_install() {
    echo 'Nix and dotfiles are installed'
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    chmod +x ~/.dotfiles/setup.sh
    bash -c "~/.dotfiles/setup.sh -c"
}

add_exec_zsh() {
    echo 'Adding `exec zsh` to `~/.bashrc`...'
    grep -qxF 'exec zsh' ~/.bashrc || echo "exec zsh" | tee -a ~/.bashrc
}

# Check if parameter is help, continue or initial
if [ "$1" == "-i" ] || [ "$1" == "--install" ]; then
    # Check if .dotfiles exists, if so stop
    if [ -d ~/.dotfiles ]; then
        echo "Home folder already contains a .dotfiles folder, please remove/move it first."
        exit 1
    fi

    # Ubuntu specific, hide login message
    hush_login

    # Install nix
    install_nix

    # Add experimental-features to nix.conf
    nix_experimental

    # Clone dotfiles
    clone_dotfiles

    # Create symbloic link to .vscode/ and .config/Code/User/
    ln -s /home/$USER/.dotfiles/vscode /home/$USER/.vscode
    ln -s /home/$USER/.dotfiles/VSCodeUser /home/$USER/.config/Code/User

    continue_install
elif [ "$1" == "-c" ] || [ "$1" == "--continue" ]; then
    # Run initial home-manager setup
    home_manager_setup

    # Run initial home-manager switch
    switch_to_home_manager

    # Add `exec zsh` to bashrc
    add_exec_zsh

    # If it's WSL
    if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
        echo 'WSL detected, adding SSH 1Password symlink...'
        sudo mkdir /opt/1Password
        sudo ln -s /mnt/c/Users/menno/AppData/Local/1Password/app/8/op-ssh-sign-wsl /opt/1Password/op-ssh-sign
    fi

    # We're done here!
    echo 'Installation complete! Please restart your shell and enjoy!'
else
    help
fi
