#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh
source ~/dotfiles/bin/lists/cargo.sh

ensure_cargo_packages_installed() {
    # Check if cargo_packages array contains duplicates
    if [ $(echo $cargo_packages | tr ' ' '\n' | sort | uniq -d | wc -l) -ne 0 ]; then
        printfe "%s\n" "red" "The cargo_packages array contains duplicates"
        printfe "%s\n" "yellow" "Duplicates:"
        printfe "%s\n" "blue" $(echo $cargo_packages | tr ' ' '\n' | sort | uniq -d)
        exit 1
    fi

    for package in $cargo_packages; do
        pkg_status=$(cargo install --list | grep -E "^${package}\sv[0-9.]+:$")
        
        # If pkg_status is `installed` then we don't need to install the package, otherwise if it's empty then the package is not installed
        if [ -z $pkg_status ]; then
            ensure_sudo_privileges "In order to install cargo_packages, please provide your password:"
            printfe "%s" "yellow" "    - Installing $package..."
            clear_line
            result=$(cargo install $package 2>&1)

            if [ $? -ne 0 ]; then
                printfe "%s\n" "red" "    - Failed to install $package"
                exit 1
            fi
            printfe "%s\n" "green" "    - Installed $package"
        else
            printfe "%s\n" "green" "    - $package is already installed"
        fi
    done
}

print_cargo_status() {
    printfe "%s" "cyan" "Checking Cargo packages..."
    clear_line

    count=$(echo $cargo_packages | wc -w)
    installed=0

    for package in $cargo_packages; do
        pkg_status=$(cargo install --list | grep -E "^${package}\sv[0-9.]+:$")

        if [ -z $pkg_status ]; then
            if [ "$verbose" = true ]; then
                printfe "%s\n" "red" "$package is not installed"
            fi
        else
            installed=$((installed + 1))
        fi
    done

    printfe "%s" "cyan" "Cargo"
    if [ $installed -eq $count ]; then
        printfe "%s" "green" " $installed/$count "
    else
        printfe "%s" "red" " $installed/$count "
    fi
    printfe "%s\n" "cyan" "packages installed"
}
