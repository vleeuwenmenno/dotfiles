HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
zstyle :compinstall filename '/home/menno/.zshrc'

autoload -Uz compinit
compinit

# Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
ENABLE_CORRECTION="false"

plugins=(
    git
    docker
    1password
    ubuntu
    sudo
    screen
    brew
    ufw
    zsh-interactive-cd
    zsh-navigation-tools
    yarn
    vscode
    composer
    laravel
    golang
    httpie
)

source $ZSH/oh-my-zsh.sh
eval "$(starship init zsh)"

#####################
# PATH Manipulation #
#####################

# Add ~/.local/bin to PATH
export PATH=$PATH:$HOME/.local/bin

# Add ~/.cargo/bin to PATH
export PATH=$PATH:$HOME/.cargo/bin

# Add dotfiles bin to PATH
export PATH=$PATH:$HOME/dotfiles/bin

#####################
# Alias Definitions #
#####################

# Aliases
alias docker-compose='docker compose'
alias gg='git pull'
alias gl='git log --stat'
alias l='eza --header --long --git --group-directories-first --group --icons --color=always --sort=name --hyperlink -o --no-permissions'
alias ll='l'
alias la='l -a'
alias ddpul='docker compose down && docker compose pull && docker compose up -d && docker compose logs -f'
alias cat='bat'

# Docker Aliases
alias d='docker'
alias dc='docker compose'
alias dce='docker compose exec'
alias dcl='docker compose logs'
alias dcd='docker compose down'
alias dcu='docker compose up'
alias dcp='docker compose ps'
alias dcps='docker compose ps'
alias dcr='docker compose run'

# Hotkeys daemon
alias hk='dotf hotkey-daemon'

# Alias for ls to l but only if it's a interactive shell because we don't want to override ls in scripts which could blow up in our face
if [ -t 1 ]; then
    alias ls='l'
fi

# Alias for ssh.exe and ssh-add.exe on Windows WSL (microsoft-standard-WSL2)
if [[ $(uname -a) == *"microsoft-standard-WSL2"* ]]; then
    alias op='op.exe'
fi

######################
# Export Definitions #
######################

# Tradaware / DiscountOffice
if [ -d "/home/menno/Projects/Work" ]; then
    export TRADAWARE_PATH=/home/menno/Projects/Work
    source $TRADAWARE_PATH/bin/helpers/source.sh
    export PATH=$PATH:$TRADAWARE_PATH/bin/utilities
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Rocm related workaround
export HSA_OVERRIDE_GFX_VERSION=11.0.0

# If $HOME/flutter exists, add it to the PATH
if [ -d "$HOME/flutter" ]; then
    export PATH="$PATH:$HOME/flutter/bin"
fi

# Flutter related environment variables
export CHROME_EXECUTABLE=/usr/bin/brave-browser

# 1Password source gh plugin
source /home/menno/.config/op/plugins.sh

#####################
# End of the line...#
#####################

# Show welcome message, but only if the terminal is interactive
if [ -t 1 ]; then
    dotf term
fi
