#!/usr/bin/env bash

source $HOME/dotfiles/bin/helpers/functions.sh

# Push all changes from $HOME/dotfiles to ALL remotes in $HOME/dotfiles/.git/config
push_all() {
    # Get all remotes from the .git/config file
    remotes=($(cat $HOME/dotfiles/.git/config | grep url | awk '{print $3}'))

    printfe "%s\n" "cyan" "Pushing all changes to all remotes..."

    # For each remote, push all changes
    for remote in $remotes; do
        printfe "%s" "green" "  - Pushing to ["
        printfe "%s" "blue" "$remote"
        printfe "%s\n" "green" "]..."

        result=$(git -C $HOME/dotfiles push $remote 2>&1)

        # If the push failed, print an error
        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "    - Failed to push to $remote:"
            printfe "%s\n" "red" "      $result"
            continue
        fi
    done
}

push_all
