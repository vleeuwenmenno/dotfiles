#!/usr/bin/env bash

ensure_tailscale_installed() {
    # if tailscale is already installed, skip the installation
    if [ -x "$(command -v tailscale)" ]; then
        printfe "%s\n" "green" "    - Tailscale is already installed"
        return
    fi

    result=$(curl -fsSL https://tailscale.com/install.sh | sh)

    # Ensure it ended with something like Installation complete
    if [[ $result == *"Installation complete"* ]]; then
        # Check if it successfully installed
        if [ -x "$(command -v tailscale)" ]; then
            printfe "%s\n" "green" "    - Tailscale is installed"
        else
            printfe "%s\n" "red" "    - Tailscale is not installed"
            printfe "%s\n" "red" "      Something went wrong while installing Tailscale, investigate the issue"
            exit 1
        fi
    else
        printfe "%s\n" "red" "    - Tailscale is not installed"
        printfe "%s\n" "red" "      Something went wrong while installing Tailscale, investigate the issue"
        exit 1
    fi

    # Let's set the current user to the operator
    sudo tailscale set --operator=$USER

    # Start the service
    tailscale up
}
