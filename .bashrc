# HISTFILE Configuration (Bash equivalent)
HISTFILE=~/.bash_history
HISTSIZE=1000
HISTFILESIZE=2000  # Adjusted to match both histfile and size criteria

# Alias Definitions
alias docker-compose='docker compose'
alias gg='git pull'
alias gl='git log --stat'
alias l="eza --header --long --git --group-directories-first --group --icons --color=always --sort=name --hyperlink -o --no-permissions"
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

# Git aliases
alias g='git'
alias gs='git status -s'
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'

# netstat port in use check
alias port='netstat -atupn | grep LISTEN'

# Hotkeys daemon
alias hk='dotf hotkey-daemon'

# Alias for ls to l but only if it's an interactive shell because we don't want to override ls in scripts which could blow up in our face
if [ -t 1 ]; then
    alias ls='l'
fi

# Alias for ssh.exe and ssh-add.exe on Windows WSL (microsoft-standard-WSL2)
if [[ $(uname -a) == *"microsoft-standard-WSL2"* ]]; then
    source $HOME/.agent-bridge.sh
    alias op='op.exe'
fi

# PATH Manipulation
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/dotfiles/bin

# Go Configuration
export GOPATH=$HOME/.go
export GOROOT=$HOME/.go-root
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Tradaware / DiscountOffice Configuration
if [ -d "/home/menno/Projects/Work" ]; then
    export TRADAWARE_FROM_SOURCE=true
fi

# pyenv Configuration
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT/bin ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
fi

# Flutter Environment
if [ -d "$HOME/flutter" ]; then
    export PATH="$PATH:$HOME/flutter/bin"
    export CHROME_EXECUTABLE=/usr/bin/brave-browser
fi

# 1Password Source Plugin (Assuming bash compatibility)
if [ -f /home/menno/.config/op/plugins.sh ]; then
    source /home/menno/.config/op/plugins.sh
fi

# Starship Prompt Initialization (Adapted for Bash)
eval "$(starship init bash)"

# Display a welcome message for interactive shells
if [ -t 1 ]; then
    dotf term
fi
