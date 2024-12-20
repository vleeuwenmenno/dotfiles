#!/usr/bin/env bash

apps=(
  spotify
  whatsapp-for-linux
  telegram-desktop
  vesktop
  trayscale
  1password
  fcitx5
  ulauncher-wrapped
)

# check if screen has any dead sessions
if screen -list | grep -q "Dead"; then
  screen -wipe
fi

echo "Starting auto-start applications..."
for app in "${apps[@]}"; do
  if [ -x "$(command -v $app)" ]; then
    if screen -list | grep -q $app; then
      echo "$app is already running. Skipping..."
      continue
    fi

    echo "Starting $app..."
    screen -dmS $app $app
    sleep 1
  fi
done

