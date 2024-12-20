#!/usr/bin/env bash

source $HOME/dotfiles/bin/helpers/functions.sh

if is_wsl; then
    output=$(op.exe item get "Dotfiles Secrets" --fields password)
else
    output=$(op item get "Dotfiles Secrets" --fields password)
fi

# Check if command was a success
if [[ $? -ne 0 ]]; then
    printfe "%s\n" "red" "Failed to fetch password from 1Password."
fi

# In case the output does not contain use 'op item get, it means the password was fetched successfully
# Without having to reveal the password using an external command
if [[ ! $output == *"use 'op item get"* ]]; then
    password=$output
else
    token=$(echo "$output" | grep -oP "(?<=\[use 'op item get ).*(?= --)")
    printfe "%s\n" "cyan" "Got fetch token: $token"

    if is_wsl; then
        password=$(op.exe item get $token --reveal --field password)
    else
        password=$(op item get $token --reveal --fields password)
    fi
fi

# only continue if password isn't empty
if [[ -z "$password" ]]; then
    printfe "%s\n" "red" "Something went wrong while fetching the password from 1Password."
    
    # Ask for manual input
    printfe "%s" "cyan" "Enter the password manually: "
    read -s password
    echo

    if [[ -z "$password" ]]; then
        printfe "%s\n" "red" "Password cannot be empty."
        exit 1
    fi

    printfe "%s\n" "green" "Password entered successfully."
fi

encrypt_folder() {
    for file in $1/*; do
        # Skip if the current file is a .gpg file
        if [[ $file == *.gpg ]]; then
            continue
        fi

        # Skip if the current file is a .sha256 file
        if [[ $file == *.sha256 ]]; then
            continue
        fi

        # If the file is a directory, call this function recursively
        if [[ -d $file ]]; then
            encrypt_folder $file
            continue
        fi

        current_checksum=$(sha256sum "$file" | awk '{ print $1 }')
        checksum_file="$file.sha256"

        if [[ -f $checksum_file ]]; then
            previous_checksum=$(cat $checksum_file)

            if [[ $current_checksum == $previous_checksum ]]; then
                continue
            fi
        fi

        # If the file has an accompanying .gpg file, remove it
        if [[ -f $file.gpg ]]; then
            rm "$file.gpg"
        fi

        printfe "%s\n" "cyan" "Encrypting $file..."
        gpg --quiet --batch --yes --symmetric --cipher-algo AES256 --armor --passphrase="$password" --output "$file.gpg" "$file"

        # Update checksum file
        echo $current_checksum > "$checksum_file"
    done
}

# Recursively decrypt all .gpg files under the folder specified, recursively call this function for sub folders!
# Keep the original file name minus the .gpg extension
decrypt_folder() {
    for file in $1/*; do
        # Skip if current file is a .gpg file
        if [[ $file == *.gpg ]]; then
            filename=$(basename $file .gpg)
            printfe "%s\n" "cyan" "Decrypting $file..."
            gpg --quiet --batch --yes --decrypt --passphrase="$password" --output $1/$filename $file
        fi

        # If file is actually a folder, call this function recursively
        if [[ -d $file ]]; then
            printfe "%s\n" "cyan" "Decrypting folder $file..."
            decrypt_folder $file
        fi
    done
}

if [[ "$1" == "decrypt" ]]; then
    printfe "%s\n" "cyan" "Decrypting secrets..."
    decrypt_folder ~/dotfiles/secrets
elif [[ "$1" == "encrypt" ]]; then
    printfe "%s\n" "cyan" "Encrypting secrets..."
    encrypt_folder ~/dotfiles/secrets
fi
