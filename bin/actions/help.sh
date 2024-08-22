#!/usr/bin/env bash

source ~/dotfiles/bin/helpers/functions.sh

# Print logo
tput setaf 2
cat ~/dotfiles/bin/resources/logo.txt
println " " "cyan"
tput sgr0

# Print help
cat ~/dotfiles/bin/resources/help.txt
println " " "cyan"
