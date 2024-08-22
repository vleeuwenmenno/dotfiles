#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh

flatpak_packages=(
    "app.drey.Doggo"
    "org.gnome.Boxes"
    "org.gnome.baobab"
    "re.sonny.Junction"
    "com.yubico.yubioath"
    "net.nokyan.Resources"
    "com.system76.Popsicle"
    "com.github.marhkb.Pods"
    "org.wezfurlong.wezterm"
    "io.github.dimtpap.coppwr"
    "com.github.tchx84.Flatseal"
    "dev.bragefuglseth.Keypunch"
    "io.github.flattool.Warehouse"
    "io.github.jonmagon.kdiskmark"
    "org.onlyoffice.desktopeditors"
    "io.missioncenter.MissionCenter"
    "io.podman_desktop.PodmanDesktop"
    "io.github.giantpinkrobots.flatsweep"
    "io.github.realmazharhussain.GdmSettings"
    "io.github.thetumultuousunicornofdarkness.cpu-x"
)

flatpak_remotes=(
    "https://flathub.org/repo/flathub.flatpakrepo"
)

ensure_remotes_added() {
    for remote in $flatpak_remotes; do
        printfe "%s\n" "green" "    - Ensuring remote $remote"
        flatpak remote-add --if-not-exists flathub $remote
    done
}

ensure_flatpak_packages_installed() {
    for package in $flatpak_packages; do
        if ! flatpak list | grep -q $package; then
            printfe "%s" "yellow" "    - Installing $package"
            result=$(flatpak install --user -y flathub $package 2>&1)

            if [ $? -ne 0 ]; then
                printfe "%s\n" "red" "Failed to install $package: $result"
            fi

            echo -en "\r"
            printfe "%s\n" "green" "    - $package installed"
        else
            printfe "%s\n" "green" "    - $package is already installed"
        fi
    done
}

print_flatpak_status() {
    printfe "%s" "cyan" "Checking Flatpak packages..."
    echo -en "\r"

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

    printfe "%s\n" "cyan" "Flatpak $installed/$count packages installed"
}