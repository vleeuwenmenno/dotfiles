#!/usr/bin/env zsh

source $HOME/dotfiles/bin/helpers/functions.sh

# Kill any running swhkd and swhks processes
if pgrep -x "swhkd" > /dev/null; then
    printfe "%s\n" "yellow" "swhkd is running, killing it..."
    sudo pkill swhkd
fi

if pgrep -x "swhks" > /dev/null; then
    printfe "%s\n" "yellow" "swhks is running, killing it..."
    sudo pkill swhks
fi

printfe "%s\n" "green" "Starting hotkey daemon..."
swhks & pkexec swhkd -c ~/.config/swhkdrc
