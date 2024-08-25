#!/usr/bin/env zsh

ensure_docker_installed() {
    # if docker is already installed, skip the installation
    if [ -x "$(command -v docker)" ]; then
        printfe "%s\n" "green" "    - Docker is already installed"
        return
    fi

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Add Docker's repository
    sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    # Check if it successfully installed
    if [ -x "$(command -v docker)" ]; then
        printfe "%s\n" "green" "    - Docker is installed"
    else
        printfe "%s\n" "red" "    - Docker is not installed"
        printfe "%s\n" "red" "      Something went wrong while installing Docker, investigate the issue"
        exit 1
    fi

    sudo usermod -aG docker $USER
    sudo systemctl start docker
    sudo systemctl enable docker
}
