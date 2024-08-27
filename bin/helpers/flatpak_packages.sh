#!/usr/bin/env zsh

source $HOME/dotfiles/bin/helpers/functions.sh

ensure_flatpak_packages_installed() {
    flatpak_packages=($(ls $HOME/dotfiles/config/flatpaks/ | sed 's/.flatpakref//g'))

    for package in $flatpak_packages; do
        if ! flatpak list | grep -q $package; then
            printfe "%s\n" "cyan" "    - Installing $package..."
            flatpak install -y flathub $package

            if [ $? -eq 0 ]; then
                printfe "%s\n" "green" "    - $package installed successfully"
            else
                printfe "%s\n" "red" "    - $package failed to install"
            fi
        else
            printfe "%s\n" "green" "    - $package is already installed"
        fi
    done
}

print_flatpak_status() {
    printfe "%s" "cyan" "Checking Flatpak packages..."
    clear_line

    flatpak_packages=($(ls $HOME/dotfiles/config/flatpaks/ | sed 's/.flatpakref//g'))

    count=$(echo $flatpak_packages | wc -w)
    installed=0

    for package in $flatpak_packages; do
        if flatpak list | grep -q $package; then
            installed=$((installed + 1))
        else
            if [ "$verbose" = true ]; then
                printfe "%s\n" "red" "$package is not installed"
            fi
        fi
    done

    printfe "%s" "cyan" "Flatpak"
    if [ $installed -eq $count ]; then
        printfe "%s" "green" " $installed/$count "
    else
        printfe "%s" "red" " $installed/$count "
    fi
    printfe "%s\n" "cyan" "packages installed"
}