#!/usr/bin/env bash

source $HOME/dotfiles/bin/helpers/functions.sh

# Print logo
tput setaf 2
cat $HOME/dotfiles/bin/resources/logo.txt
println " " "cyan"
tput sgr0

# Print help
cat $HOME/dotfiles/bin/resources/help.txt
println " " "cyan"
