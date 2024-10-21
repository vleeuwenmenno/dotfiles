#!/usr/bin/env bash

source $HOME/dotfiles/bin/helpers/functions.sh

####################################################################################################
# Decrypt secrets
####################################################################################################
printfe "%s\n" "cyan" "Fetching password from 1Password..."
echo -en '\r'

# if WSL alias op to op.exe
if [[ $(uname -a) == *"microsoft-standard-WSL2"* ]]; then
    alias op="op.exe"
else
    alias op="op"
fi

output=$(op item get "Dotfiles Secrets" --fields password)

# Check if the password was found
if [[ -z "$output" ]]; then
    printfe "%s\n" "red" "Password not found in 1Password, add a login item with the name 'Dotfiles Secrets' and give it a password."
    exit 1
fi

command=$(echo "$output" | grep -oP "(?<=use ').*(?=')")
password=$(eval $command | grep -oP "(?<=  password:    ).*" | tr -d '\n')

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
            printfe "%s\n" "cyan" "Encrypting folder $file..."
            encrypt_folder $file
            continue
        fi

        current_checksum=$(sha256sum "$file" | awk '{ print $1 }')
        checksum_file="$file.sha256"

        if [[ -f $checksum_file ]]; then
            previous_checksum=$(cat $checksum_file)

            if [[ $current_checksum == $previous_checksum ]]; then
                printfe "%s\n" "green" "Skipping unchanged file $file."
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

if [[ "$2" == "decrypt" ]]; then
    decrypt_folder ~/dotfiles/secrets
elif [[ "$2" == "encrypt" ]]; then
    encrypt_folder ~/dotfiles/secrets
fi