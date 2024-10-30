#!/usr/bin/env bash

apps=(
  spotify
  whatsapp-for-linux
  telegram-desktop
  vesktop
  trayscale
  1password
)

echo "Starting auto-start applications..."
for app in "${apps[@]}"; do
  if [ -x "$(command -v $app)" ]; then
    echo "Starting $app..."
    screen -dmS $app $app
    sleep 1
  fi
done
