#!/usr/bin/env bash

source $HOME/dotfiles/bin/helpers/functions.sh

ensure_gnome_extensions_installed() {
    # In case gnome-extensions is installed but we don't use GNOME let's do a check
    if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
        printfe "%s\n" "red" "    - XDG_CURRENT_DESKTOP is not GNOME, likely not running GNOME."
        return
    fi

    # Attempt to connect to GNOME shell, if it fails, we can stop here
    if ! gnome-extensions &> /dev/null; then
        printfe "%s\n" "red" "    - gnome-extensions command not found, likely not running GNOME?!"
        return
    fi

    printfe "%s" "cyan" "  - Loading GNOME extension json file..."
    echo -en '\r'

    if [ ! -f ~/dotfiles/gnome/extensions.json ]; then
        printfe "%s\n" "red" "  - No GNOME extensions file found."
        return
    fi

    extensions=$(cat ~/dotfiles/gnome/extensions.json)
    gnome_extensions=($(echo $extensions | jq -r '.[]'))

    for i in "${gnome_extensions[@]}";
    do
        printfe "%s" "cyan" "    - Fetching extension details for $(echo $i | grep -oP 'extension/\K[^/]+')"
        echo -en '\r'

        # Check if extension_id is already installed
        if gnome-extensions list | grep --quiet ${i}; then
            printfe "%s\n" "green" "    - Extension $i is already installed."
            continue
        fi

        printfe "%s" "cyan" "    - Installing $i..."
        echo -en '\r'

        result=$(gext install $i 2>&1)
        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "    - Failed to install $i"
            printfe "%s\n" "red" "      $result"
            continue
        fi

        if echo $result | grep --quiet "Cannot find extension"; then
            printfe "%s\n" "red" "    - Failed to install $i, extension not found."
            continue
        fi

        printfe "%s\n" "green" "    - Extension $i has been installed."
    done
}

# Export a JSON file with all installed GNOME extensions IDs
export_gnome_extensions() {
    # Only export if we have the gnome-extensions command
    if ! command -v gnome-extensions &> /dev/null; then
        printfe "%s\n" "red" "    - gnome-extensions command not found, likely not running GNOME."
        return
    fi

    extensions=$(gnome-extensions list --enabled --user)
    echo $extensions | jq -R -s -c 'split("\n")[:-1]' > ~/dotfiles/gnome/extensions.json
}
