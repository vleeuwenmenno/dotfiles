#!/usr/bin/env zsh

source $HOME/dotfiles/bin/helpers/functions.sh

ensure_rust_installed() {
    if [ -x "$(command -v rustc)" ]; then
        printfe "%s\n" "green" "    - Rust is already installed"

        # Update Rust
        printfe "%s" "yellow" "    - Updating Rust..."
        echo -en "\r"

        rustup update
    else
        printfe "%s\n" "yellow" "    - Installing Rust..."
        echo -en "\r"

        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "Failed to install Rust"
            exit 1
        fi
        rustup default stable

        printfe "%s\n" "green" "    - Rust installed successfully"
    fi
}
