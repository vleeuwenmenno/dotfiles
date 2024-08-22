#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh

####################################################################################################
# Decrypt secrets
####################################################################################################
printfe "%s\n" "cyan" "Fetching password from 1Password..."
echo -en '\r'

output=$(op item get "SSH Config Secrets" --fields password)

# Check if the password was found
if [[ -z "$output" ]]; then
    printfe "%s\n" "red" "Password not found in 1Password, add a login item with the name 'SSH Config Secrets' and give it a password."
    exit 1
fi

command=$(echo "$output" | grep -oP "(?<=use ').*(?=')")
password=$(eval $command | grep -oP "(?<=  password:    ).*" | tr -d '\n')

# Check what we are supposed to do (Either decrypt or encrypt)
if [[ "$2" == "decrypt" ]]; then
    printfe "%s\n" "cyan" "Decrypting .ssh/config.d/ files..."
    echo -en '\r'

    for file in ~/.ssh/config.d/*.gpg; do
        filename=$(basename $file .gpg)
        gpg --quiet --batch --yes --decrypt --passphrase="$password" --output ~/.ssh/config.d/$filename $file
    done
elif [[ "$2" == "encrypt" ]]; then
    printfe "%s\n" "cyan" "Encrypting .ssh/config.d/ files..."
    echo -en '\r'

    for file in ~/.ssh/config.d/*; do
        # Skip if current file is a .gpg file
        if [[ $file == *.gpg ]]; then
            continue
        fi

        # If the file has a accompanying .gpg file, remove it
        if [[ -f $file.gpg ]]; then
            rm $file.gpg
        fi

        gpg --quiet --batch --yes --symmetric --cipher-algo AES256 --armor --passphrase="$password" --output $file.gpg $file
        rm $file
    done
else
    printfe "%s\n" "red" "Invalid argument. Use 'decrypt' or 'encrypt'"
    exit 1
fi
