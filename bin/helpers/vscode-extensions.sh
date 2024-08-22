#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh

load_vscode_extensions() {
    # Clear the array before populating it
    arr=()
    while IFS= read -r line; do
        arr+=("$line")
    done < <(jq -r '.[]' ~/dotfiles/vscode/extensions.json)    
    # Export the array
    export extensionList=("${arr[@]}")
}

ensure_vscode_extensions_installed() {
    # Load extensions list from jq in ~/dotfiles/vscode/extensions.json
    load_vscode_extensions

    for extension in "${extensionList[@]}"; do
        result=$(code --list-extensions | grep -E "^${extension}$")
        if [ -z "$result" ]; then
            printfe "%s" "yellow" "Installing $extension..."
            code --install-extension $extension

            if [ $? -ne 0 ]; then
                printfe "%s\n" "red" "Failed to install $extension"
                exit 1
            fi
            printfe "%s\n" "green" "Installed $extension"
        else
            printfe "%s\n" "green" "$extension is already installed"
        fi
    done
}
