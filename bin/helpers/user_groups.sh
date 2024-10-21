#!/usr/bin/env bash

source $HOME/dotfiles/bin/helpers/functions.sh

ensure_user_groups() {
    # Load yaml file
    users=($(cat $DOTFILES_CONFIG | shyaml keys config.user_groups))

    # For each user, ensure they are in the correct groups
    for user in $users; do
        # Ensure this user exists
        if [[ ! $(id -u $user) ]]; then
            printfe "%s\n" "red" "    - User $user does not exist"
            continue
        fi

        ensure_user_in_groups $user
    done
}

ensure_user_in_groups() {
    user=$1
    groups=($(cat $DOTFILES_CONFIG | shyaml get-values config.user_groups.$user))

    printfe "%s\n" "cyan" "    - For user $user..."

    # For each group, ensure the user is in it
    for group in $groups; do
        # Check if the group exists at all, otherwise skip
        if [[ ! $(getent group $group) ]]; then
            printfe "%s\n" "red" "      Group $group does not exist"
            continue
        fi

        if [[ ! $groups == *$group* ]]; then
            printfe "%s\n" "green" "      Adding $user to group $group"
            sudo usermod -aG $group $user
        else
            printfe "%s\n" "green" "      $user is already in group $group"
        fi
    done
}
