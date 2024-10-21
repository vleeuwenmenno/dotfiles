#!/bin/bash

# Prepare, we need at least these minimal packages to continue ...
sudo apt update
sudo apt install curl nala pipx apt-transport-https ca-certificates gnupg -y

# Ensure shyaml is available
echo "Ensuring shyaml is installed..."
if [ ! -x "$(command -v shyaml)" ]; then
    echo "    - shyaml is not installed, installing it..."
    pipx install shyaml
fi

echo "Ensuring pyenv is installed..."
if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
else
    echo "    - pyenv is already installed"
fi

sed -i -e '$a\'$'\n''export PATH=$PATH:$HOME/.local/bin' ~/.bashrc
sed -i -e '$a\'$'\n''export PATH=$PATH:~/dotfiles/bin' ~/.bashrc
sed -i -e '$a\'$'\n''export PATH=$PATH:$HOME/.local/bin' ~/.zshrc
sed -i -e '$a\'$'\n''export PATH=$PATH:~/dotfiles/bin' ~/.zshrc

echo "#########################################################"
echo "#                                                       #"
echo "# !!!   RESTART YOUR TERMINAL BEFORE YOU CONTINUE   !!! #"
echo "# !!!           Continue with 'dotf update'         !!! #"
echo "#                                                       #"
echo "#########################################################"
