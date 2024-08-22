#!/usr/bin/env zsh

packages=(
    "zsh"
    "git"
    "curl"
    "wget"
    "vim"
    "tmux"
    "sl"
    "just"
    "libglvnd-dev"
    "libwayland-dev"
    "libseat-dev"
    "libxkbcommon-dev"
    "libinput-dev"
    "udev"
    "dbus"
    "libdbus-1-dev"
    "libsystemd-dev"
    "libpixman-1-dev"
    "libssl-dev"
    "libflatpak-dev"
    "libpulse-dev"
    "libexpat1-dev"
    "libfontconfig-dev"
    "libfreetype-dev"
    "mold"
    "cargo"
    "libgbm-dev"
    "libclang-dev"
    "libpipewire-0.3-dev"
    "libpam0g-dev"
    "openssh-server"
    "build-essential"
    "flatpak"
    "meson"
    "pipx"
    "python3-nautilus"
    "gettext"
    "fzf"
    "neofetch"
    "screenfetch"
)

ensure_packages_installed() {
    ensure_sudo_privileges "In order to install packages, please provide your password:"

    # Check if packages array contains duplicates
    if [ $(echo $packages | tr ' ' '\n' | sort | uniq -d | wc -l) -ne 0 ]; then
        printfe "%s\n" "red" "The packages array contains duplicates"
        printfe "%s\n" "yellow" "Duplicates:"
        printfe "%s\n" "blue" $(echo $packages | tr ' ' '\n' | sort | uniq -d)
        exit 1
    fi

    for package in $packages; do
        pkg_status=$(dpkg -s $package 2> /dev/null | grep "Status" | cut -d " " -f 4)

        # If pkg_status is `installed` then we don't need to install the package, otherwise if it's empty then the package is not installed
        if [ -z $pkg_status ]; then
            printfe "%s" "yellow" "Installing $package..."
            echo -en "\r"

            sudo apt install -y $package &> /dev/null

            if [ $? -ne 0 ]; then
                printfe "%s\n" "red" "Failed to install $package"
                exit 1
            else
                printfe "%s\n" "green" "$package installed successfully"
            fi
        else
            printfe "%s\n" "green" "$package is already installed"
        fi
    done
}
