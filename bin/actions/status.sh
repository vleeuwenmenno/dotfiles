#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh
source ~/dotfiles/bin/helpers/packages.sh
source ~/dotfiles/bin/helpers/vscode-extensions.sh

# Check if parameter --verbose was passed
if [ "$2" = "--verbose" ]; then
    verbose=true
else
    verbose=false
fi

# count entries in packages
count=$(echo $packages | wc -w)
installed=0

for package in $packages; do
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

total_extensions=${#extensionList[@]}
printfe "%s\n" "cyan" "VSCode $count_installed_extensions/$total_extensions extensions installed"
