#!/usr/bin/env bash

source $HOME/dotfiles/bin/helpers/functions.sh

welcome() {
  echo
  tput setaf 6
  printf "You're logged in on ["
  printf $HOSTNAME | lolcat
  tput setaf 6
  printf "] as "
  printf "["
  printf $USER | lolcat
  tput setaf 6
  printf "]\n"
  tput sgr0
}

logo continue
welcome
