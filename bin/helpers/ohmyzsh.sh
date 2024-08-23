#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh

ensure_ohmyzsh_installed() {
    if [ -d ~/.oh-my-zsh ]; then
        printfe "%s" "yellow" "    - Updating Oh My Zsh..."
        echo -en "\r"

        zstyle ':omz:update' verbose minimal
        result=$($ZSH/tools/upgrade.sh)

        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "Failed to update Oh My Zsh"
            exit 1
        fi

        # if result contains "already at the latest version" then it's already up to date and we should say so
        if [[ $result == *"already at the latest version"* ]]; then
            printfe "%s\n" "green" "    - Oh My Zsh is already up to date"
        else
            printfe "%s\n" "green" "    - Oh My Zsh updated successfully"
            printfe "%s\n" "green" "$result"
        fi
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}
