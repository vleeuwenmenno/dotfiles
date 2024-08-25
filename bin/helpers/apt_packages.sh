#!/usr/bin/env zsh

source $HOME/dotfiles/bin/helpers/functions.sh

add_brave_repo() {
    # Check if we have a brave-browser-release.list file already, if not then create one
    if [ ! -f /etc/apt/sources.list.d/brave-browser-release.list ]; then
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        result=$(sudo apt update 2>&1)

        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "    - Failed to add Brave repository"
            printfe "%s\n" "yellow" "$result"
            exit 1
        fi

        printfe "%s\n" "yellow" "    - Added Brave repository"
    else
        printfe "%s\n" "green" "    - Brave repository already added"
    fi
}

add_1password_repo() {
    # Check if we have a 1password.list file already, if not then create one
    if [ ! -f /etc/apt/sources.list.d/1password.list ]; then
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
        result=$(sudo apt update 2>&1)

        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "    - Failed to add 1Password repository"
            printfe "%s\n" "yellow" "$result"
            exit 1
        fi

        printfe "%s\n" "yellow" "    - Added 1Password repository"
    else
        printfe "%s\n" "green" "    - 1Password repository already added"
    fi
}

add_spotify_repo() {
    # Check if we have a spotify.list file already, if not then create one
    if [ ! -f /etc/apt/sources.list.d/spotify.list ]; then
        curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        result=$(sudo apt update 2>&1)

        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "    - Failed to add Spotify repository"
            printfe "%s\n" "yellow" "$result"
            exit 1
        fi

        printfe "%s\n" "yellow" "    - Added Spotify repository"
    else
        printfe "%s\n" "green" "    - Spotify repository already added"
    fi
}

add_vscode_repo() {
    # Check if we have a vscode.list file already, if not then create one
    if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        rm -f packages.microsoft.gpg
        result=$(sudo apt update 2>&1)

        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "    - Failed to add VSCode repository"
            printfe "%s\n" "yellow" "$result"
            exit 1
        fi

        printfe "%s\n" "yellow" "    - Added VSCode repository"
    else
        printfe "%s\n" "green" "    - VSCode repository already added"
    fi
}

ensure_repositories() {
    add_brave_repo
    add_1password_repo
    add_spotify_repo
    add_vscode_repo

    repos=($(cat $DOTFILES_CONFIG | shyaml get-values config.packages.apt.repos))
    for repo in $repos; do
        repo_name=$(echo $repo | cut -d ":" -f 2)

        # Go through sources.list.d and check if there's a file containing part of URIs: https://ppa.launchpad.net/$repo_name
        # We have to check the files not the file names since the file names are not always the same as the repo_name
        result=$(grep -r "$repo_name" /etc/apt/sources.list.d/*)
        if [ -z "$result" ]; then
            printfe "%s\n" "yellow" "    - Adding $repo_name repository..."
            clear_line

            sudo add-apt-repository -y $repo

            if [ $? -ne 0 ]; then
                printfe "%s\n" "red" "    - Failed to add $repo_name repository"
                exit 1
            else
                printfe "%s\n" "green" "    - $repo_name repository added successfully"
            fi
        else
            printfe "%s\n" "green" "    - $repo_name repository already added"
        fi
    done
}
ensure_apt_packages_installed() {
    apt_packages=($(cat $DOTFILES_CONFIG | shyaml get-values config.packages.apt.apps))

    # Check if apt_packages array contains duplicates
    if [ $(echo $apt_packages | tr ' ' '\n' | sort | uniq -d | wc -l) -ne 0 ]; then
        printfe "%s\n" "red" "The apt_packages array contains duplicates"
        printfe "%s\n" "yellow" "Duplicates:"
        printfe "%s\n" "blue" $(echo $apt_packages | tr ' ' '\n' | sort | uniq -d)
        exit 1
    fi

    for package in $apt_packages; do
        pkg_status=$(dpkg -s $package 2> /dev/null | grep "Status" | cut -d " " -f 4)

        # If pkg_status is `installed` then we don't need to install the package, otherwise if it's empty then the package is not installed
        if [ -z $pkg_status ]; then
            ensure_sudo_privileges "In order to install $package, please provide your password:"

            printfe "%s" "yellow" "    - Installing $package..."
            clear_line

            result=$(sudo apt install -y $package 2>&1)

            if [ $? -ne 0 ]; then
                printfe "%s\n" "red" "    - Failed to install $package"
                printfe "%s\n" "yellow" "$result"
                exit 1
            else
                printfe "%s\n" "green" "    - $package installed successfully"
            fi
        else
            printfe "%s\n" "green" "    - $package is already installed"
        fi
    done
}

print_apt_status() {
    printfe "%s" "cyan" "Checking APT packages..."
    clear_line

    apt_packages=($(cat $DOTFILES_CONFIG | shyaml get-values config.packages.apt.apps))
    
    # count entries in packages
    count=$(echo $apt_packages | wc -w)
    installed=0

    for package in $apt_packages; do
        pkg_status=$(dpkg -s $package 2> /dev/null | grep "Status" | cut -d " " -f 4)

        if [ "$pkg_status" = "installed" ]; then
            installed=$((installed + 1))
        else
            if [ "$verbose" = true ]; then
                printfe "%s\n" "red" "$package is not installed"
            fi
        fi
    done

    printfe "%s" "cyan" "APT"
    if [ $installed -eq $count ]; then
        printfe "%s" "green" " $installed/$count "
    else
        printfe "%s" "red" " $installed/$count "
    fi
    printfe "%s\n" "cyan" "packages installed"
}
