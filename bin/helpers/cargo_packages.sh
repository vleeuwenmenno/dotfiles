#!/usr/bin/env zsh

source $HOME/dotfiles/bin/helpers/functions.sh

ensure_cargo_packages_installed() {
    cargo_packages=($(cat $DOTFILES_CONFIG | shyaml keys config.packages.cargo))
    for package in "${cargo_packages[@]}"; do 
        printfe "%s" "cyan" "  - Checking $package..."
        echo -en '\r'

        # Some entries have a git_url and binary, we need to load these in if they exist
        pkg_status=$(cargo install --list | grep -E "^${package}\sv[0-9.]+:$")
        package_url=$(cat $DOTFILES_CONFIG | shyaml get-value config.packages.cargo.$package.git_url 2>/dev/null)
        binary=$(cat $DOTFILES_CONFIG | shyaml get-value config.packages.cargo.$package.binary 2>/dev/null)
        
        # If pkg_status is `installed` then we don't need to install the package, otherwise if it's empty then the package is not installed
        if [ -z $pkg_status ]; then
            ensure_sudo_privileges "In order to install $package, please provide your password:"
            printfe "%s" "yellow" "    - Compiling/Installing $package... (This may take a while)"
            clear_line

            # If package_url is defined we should install via git
            if [ -n "$package_url" ]; then
                command="cargo install --git $package_url $binary"
            else
                command="cargo install $package"
            fi

            # Execute the command
            result=$(eval $command 2>&1)
            
            if [ $? -ne 0 ]; then
                printfe "%s\n" "red" "    - Failed to install $package"
                printfe "%s\n" "red" "      Command: $command"
                printfe "%s\n" "red" "      Output: $result"
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

    cargo_packages=($(cat $DOTFILES_CONFIG | shyaml keys config.packages.cargo))
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
