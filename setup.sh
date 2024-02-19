#!/bin/bash
NIX_CONFIG_URL="https://gist.githubusercontent.com/vleeuwenmenno/4671a99beca2e45dc4b0211de7865dfe/raw/8eb0656fe956db81b18d31caad54aaff66298e0a/nix.conf"

help() {
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -i, --init        Initial installation"
    echo "   -c, --continue    Continue installation"
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

        echo 'Please restart your shell to continue...'
        touch ~/.setup-initial-done
    fi
}

hush_login() {
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

# Check if parameter is help, continue or initial
if [ "$1" == "-c" ] || [ "$1" == "--continue" ]; then
    rm ~/.setup-initial-done

    # Add experimental-features to nix.conf
    nix_experimental

    # Insert nix configuration from github gist
    nix_config_import

    
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    help
elif [ "$1" == "-i" ] || [ "$1" == "--init" ]; then
    # Ubuntu specific, hide login message
    hush_login

    # Install nix
    install_nix
else
    help
fi


