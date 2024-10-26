#!/usr/bin/env bash

source $HOME/dotfiles/bin/helpers/functions.sh

ensure_git_repos() {
    # Load config file with git repos:
    repos=($(cat $HOME/dotfiles/config/config.yaml | shyaml keys config.git))

    # For each repo in the config file, ensure it is cloned (url + branch, if specified)
    for repo in "${repos[@]}"; do
        url=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.git.$repo.url)
        branch=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.git.$repo.branch)
        target=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.git.$repo.target)
        target_dirty=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.git.$repo.target)

        # Replace ~ with $HOME
        target="${target/#\~/$HOME}"

        # If no url is specified, skip this repo
        if [ -z "$url" ]; then
            printfe "%s\n" "red" "    - No URL specified for $repo, skipping"
            continue
        fi

        # If no branch is specified, default to main
        if [ -z "$branch" ]; then
            branch="main"
            printfe "%s\n" "yellow" "    - No branch specified for $repo, defaulting to $branch"
        fi

        # If no target is specified, stop since we have no idea where to expect to put the repo
        if [ -z "$target" ]; then
            printfe "%s\n" "red" "    - No target specified for $repo, skipping"
            continue
        fi

        # If the target directory does not exist, clone the repo there with the specified branch
        if [ ! -d "$target" ]; then
            printfe "%s\n" "green" "    - Cloning $repo to $target"
            result=$(git clone --branch $branch $url $target 2>&1)

            # If the clone failed, print an error
            if [ $? -ne 0 ]; then
                printfe "%s\n" "red" "    - Failed to clone $repo to $target:"
                printfe "%s\n" "red" "        $result"
                continue
            fi
        else
            # If the target directory exists, check if it is a git repo
            if [ -d "$target/.git" ]; then
                # If it is a git repo, check if the remote is the same as the one specified in the config file
                remote=$(git -C $target remote get-url origin)
                if [ "$remote" != "$url" ]; then
                    # If the remote is different, print a warning
                    printfe "%s" "yellow" "    - $target is a git repo, but the remote (origin) is different from the one in the config file. Replace it? [y/N] "
                    read -n 1
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        printfe "%s\n" "green" "    - Replacing remote in $target with $url"
                        git -C $target remote set-url origin $url
                    fi

                    # Fast-forward the repo but only if it's in the correct branch
                    current_branch=$(git -C $target rev-parse --abbrev-ref HEAD)
                    if [ "$current_branch" != "$branch" ]; then
                        printfe "%s\n" "yellow" "    - $target is a git repo, but it's not in the expected branch ($current_branch instead of $branch)"
                    else
                        printfe "%s\n" "green" "    - Fast-forwarding $target"
                        result=$(git -C $target pull 2>&1)

                        # If the pull failed, print an error
                        if [ $? -ne 0 ]; then
                            printfe "%s\n" "red" "    - Failed to fast-forward $target:"
                            printfe "%s\n" "red" "        $result"
                        fi
                    fi
                else
                    # Fast-forward the repo but only if it's in the correct branch
                    current_branch=$(git -C $target rev-parse --abbrev-ref HEAD)
                    if [ "$current_branch" != "$branch" ]; then
                        printfe "%s\n" "yellow" "    - $target is a git repo, but it's not in the expected branch ($current_branch instead of $branch)"
                    else
                        printfe "%s\n" "green" "    - Fast-forwarding $target"
                        result=$(git -C $target pull 2>&1)

                        # If the pull failed, print an error
                        if [ $? -ne 0 ]; then
                            printfe "%s\n" "red" "    - Failed to fast-forward $target:"
                            printfe "%s\n" "red" "        $result"
                        fi
                    fi
                fi
            else
                # If the target directory exists but is not a git repo, print a warning
                printfe "%s\n" "red" "    - $target exists but is not a git repo?! Skipping"
            fi
        fi

        # Print state of the repo example: "repo (branch) -> [target] ([untracked files] [unstaged changes] [staged changes] [unpushed commits])"
        untracked=$(git -C $target status --porcelain | grep -c '^??')
        unstaged=$(git -C $target status --porcelain | grep -c '^ M')
        staged=$(git -C $target status --porcelain | grep -c '^M ')
        unstaged_changes=$(git -C $target status --porcelain | grep -c '^M')
        unpushed_commits=$(git -C $target log origin/$branch..HEAD --oneline | wc -l | tr -d ' ')

        printfe "%s" "blue" "    - $repo ($branch) -> [$target_dirty]"
        if [ $untracked -gt 0 ]; then
            printfe "%s" "red" " [$untracked] untracked"
        fi

        if [ $unstaged -gt 0 ]; then
            printfe "%s" "yellow" " [$unstaged] modified"
        fi

        printfe "%s" "green" " [$staged]"

        if [ $unstaged_changes -gt 0 ]; then
            printfe "%s" "red" " [$unstaged_changes] unstaged changes"
        fi

        if [ $unpushed_commits -gt 0 ]; then
            printfe "%s" "yellow" " [!] You have [$unpushed_commits] unpushed commits"
        fi

        echo
    done
}
