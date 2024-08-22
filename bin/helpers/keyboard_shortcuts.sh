#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq could not be found, please install it."
    exit 1
fi

# Parse JSON file
shortcuts_file=~/dotfiles/config/keyboard-shortcuts.json
if [ ! -f "${shortcuts_file}" ]; then
    echo "Shortcuts file not found: ${shortcuts_file}"
    exit 1
fi

shortcuts=$(jq -r '.shortcuts' "${shortcuts_file}")

ensure_keyboard_shortcuts() {
    # Retrieve current custom keybindings
    existing_bindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings | tr -d "[]'")
    new_bindings=()
    index=0

    # Iterate over parsed JSON shortcuts
    for key_combination in $(echo "$shortcuts" | jq -r 'keys[]'); do
        command=$(echo "$shortcuts" | jq -r ".[\"$key_combination\"]")

        printfe '%s\n' "green" "    - Ensuring custom shortcut ${key_combination} command ${command}"

        custom_binding="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${index}/"
        new_bindings+=("$custom_binding")

        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"${custom_binding}" name "${key_combination} to run ${command}"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"${custom_binding}" command "${command}"
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"${custom_binding}" binding "${key_combination}"
        dconf write "${custom_binding}enabled" true

        ((index++))
    done

    new_bindings_string=$(printf "'%s', " "${new_bindings[@]}")
    new_bindings_string="[${new_bindings_string%, }]"

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "${new_bindings_string}"
}

print_keyboard_shortcuts_status() {
    printfe "%s" "cyan" "Checking keyboard shortcuts..."
    echo -en "\r"

    # Retrieve current custom keybindings
    existing_bindings=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings | tr -d "[]'")
    existing_count=$(echo $existing_bindings | tr -cd , | wc -c)

    # Iterate over parsed JSON shortcuts
    for key_combination in $(echo "$shortcuts" | jq -r 'keys[]'); do
        command=$(echo "$shortcuts" | jq -r ".[\"$key_combination\"]")

        if [[ ! $existing_bindings =~ "custom${index}" ]]; then
            printfe "%s\n" "red" "    - Custom shortcut ${key_combination} is missing"
        fi

        ((index++))
    done

    json_count=$(echo $shortcuts | jq 'keys | length')
    printfe "%s\n" "cyan" "Keyboard shortcuts $index/$json_count configured"
}