#!/usr/bin/env bash

source $HOME/dotfiles/bin/helpers/functions.sh

ensure_pipx_packages_installed() {
    pipx_packages=($(cat $DOTFILES_CONFIG | shyaml get-values config.packages.pipx))
    for i in "${pipx_packages[@]}";
    do
        printfe "%s" "cyan" "    - Fetching package details for $i"
        echo -en '\r'

        if pipx list | grep --quiet ${i}; then
            printfe "%s\n" "green" "    - $i is already installed."
            continue
        fi

        printfe "%s" "cyan" "    - Installing $i..."
        echo -en '\r'

        pipx install $i
        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "    - Failed to install $i"
            continue
        fi

        printfe "%s\n" "green" "    - $i installed."
    done
}

print_pipx_status() {
    printfe "%s" "cyan" "Checking pipx packages..."
    clear_line

    pipx_packages=($(cat $DOTFILES_CONFIG | shyaml get-values config.packages.pipx))
    count=$(echo $pipx_packages | wc -w)
    installed=0

    for package in $pipx_packages; do
        if pipx list | grep -q $package; then
            installed=$((installed + 1))
        else
            if [ "$verbose" = true ]; then
                printfe "%s\n" "red" "$package is not installed"
            fi
        fi
    done

    printfe "%s" "cyan" "pipx"
    if [ $installed -eq $count ]; then
        printfe "%s" "green" " $installed/$count "
    else
        printfe "%s" "red" " $installed/$count "
    fi
    printfe "%s\n" "cyan" "packages installed"
}
