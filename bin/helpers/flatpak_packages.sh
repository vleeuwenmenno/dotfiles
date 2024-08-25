#!/usr/bin/env zsh

source $HOME/dotfiles/bin/helpers/functions.sh

ensure_remotes_added() {
    flatpak_remotes=($(cat $DOTFILES_CONFIG | shyaml get-values config.packages.flatpak.remotes))

    for remote in $flatpak_remotes; do
        printfe "%s\n" "green" "    - Ensuring remote $remote"
        flatpak remote-add --if-not-exists flathub $remote
    done
}

ensure_flatpak_packages_installed() {
    flatpak_packages=($(cat $DOTFILES_CONFIG | shyaml get-values config.packages.flatpak.apps))
    for package in $flatpak_packages; do
        if ! flatpak list | grep -q $package; then
            printfe "%s" "yellow" "    - Installing $package"
            result=$(flatpak install --user -y flathub $package 2>&1)

            if [ $? -ne 0 ]; then
                printfe "%s\n" "red" "Failed to install $package: $result"
            fi

            clear_line
            printfe "%s\n" "green" "    - $package installed"
        else
            printfe "%s\n" "green" "    - $package is already installed"
        fi
    done
}

print_flatpak_status() {
    printfe "%s" "cyan" "Checking Flatpak packages..."
    clear_line

    flatpak_packages=($(cat $DOTFILES_CONFIG | shyaml get-values config.packages.flatpak.apps))

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