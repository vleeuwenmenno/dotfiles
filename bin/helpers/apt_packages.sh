#!/usr/bin/env zsh

apt_packages=(
    "zsh"
    "git"
    "curl"
    "wget"
    "vim"
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
    "wezterm"
    "brave-browser"
    "code"
    "1password"
    "1password-cli"
    "spotify-client"
    "yq"
)

add_wezterm_repo() {
    # Check if we have a wezterm.list file already, if not then create one
    if [ ! -f /etc/apt/sources.list.d/wezterm.list ]; then
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
        result=$(sudo apt update 2>&1)

        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "    - Failed to add Wezterm repository"
            printfe "%s\n" "yellow" "$result"
            exit 1
        fi

        printfe "%s\n" "yellow" "    - Added Wezterm repository"
    else
        printfe "%s\n" "green" "    - Wezterm repository already added"
    fi
}

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
    if [ "$verbose" = true ]; then
        printfe "%s\n" "cyan" "Installing common dependencies..."
    fi
    result=$(sudo apt install wget gpg ca-certificates curl software-properties-common apt-transport-https 2>&1)

    if [ $? -ne 0 ]; then
        printfe "%s\n" "red" "    - Failed to install common dependencies"
        printfe "%s\n" "yellow" "$result"
        exit 1
    fi

    add_wezterm_repo
    add_brave_repo
    add_1password_repo
    add_spotify_repo
    add_vscode_repo
}

ensure_apt_packages_installed() {
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
            echo -en "\r"

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
    echo -en "\r"

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

    printfe "%s\n" "cyan" "APT $installed/$count packages installed"
}
