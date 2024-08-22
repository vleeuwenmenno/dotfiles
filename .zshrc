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
    tmux
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

# Activate Starship
eval "$(starship init zsh)"

# Aliases
alias docker-compose='docker compose'
alias gg='git pull'
alias gl='git log --stat'
alias l='lsd -Sl --reverse --human-readable --group-directories-first'
alias mv='/usr/local/bin/advmv -g'
alias cp='/usr/local/bin/advcp -g'
alias ddpul='docker compose down && docker compose pull && docker compose up -d && docker compose logs -f'

# Tradaware / DiscountOffice
export TRADAWARE_PATH=/Users/menno/Projects/Work/infra
source $TRADAWARE_PATH/bin/helpers/source.sh

# 1Password SSH Socket (Linux/macOS)
export SSH_AUTH_SOCK=~/.1password/agent.sock
# export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

