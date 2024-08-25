#!/usr/bin/env zsh

source $HOME/dotfiles/bin/helpers/functions.sh

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
            printfe "%s" "yellow" "    - Installing $extension..."
            code --install-extension $extension

            if [ $? -ne 0 ]; then
                printfe "%s\n" "red" "    - Failed to install $extension"
                exit 1
            fi
            printfe "%s\n" "green" "    - Installed $extension"
        else
            printfe "%s\n" "green" "    - $extension is already installed"
        fi
    done
}

print_vsc_status() {
    printfe "%s" "cyan" "Checking VSCode extensions..."
    clear_line

    load_vscode_extensions
    count_installed_extensions=0

    # Loop through each extension and check if it's installed
    for extension in "${extensionList[@]}"; do
        result=$(code --list-extensions | grep -E "^${extension}$")
        if [ -z "$result" ]; then
            if [ "$verbose" = true ]; then
                printfe "%s" "yellow" "Extension $extension is not installed\n"
            fi
        else
            count_installed_extensions=$((count_installed_extensions + 1))
        fi
    done

    if [ "$verbose" = true ]; then
        printfe "%s\n" "yellow" "Expected extensions:"
        for ext in "${extensionList[@]}"; do
            printfe "%s\n" "blue" "$ext"
        done

        printfe "%s\n" "yellow" "Installed extensions:"
        while IFS= read -r installed_ext; do
            printfe "%s\n" "blue" "$installed_ext"
        done < <(code --list-extensions)
    fi

    count=${#extensionList[@]}

    printfe "%s" "cyan" "VSCode"
    if [ $count_installed_extensions -eq $count ]; then
        printfe "%s" "green" " $count_installed_extensions/$count "
    else
        printfe "%s" "red" " $count_installed_extensions/$count "
    fi
    printfe "%s\n" "cyan" "extensions installed"
}
