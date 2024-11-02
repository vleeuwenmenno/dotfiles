# HISTFILE Configuration (Bash equivalent)
HISTFILE=~/.bash_history
HISTSIZE=1000
HISTFILESIZE=2000  # Adjusted to match both histfile and size criteria

# Alias Definitions
alias docker-compose='docker compose'
alias gg='git pull'
alias gl='git log --stat'

# Home Manager Configuration
alias hm='cd $HOME/dotfiles/config/home-manager/ && home-manager'
alias hmnews='hm news --flake .#$DOTF_HOSTNAME'
alias hmup='hm switch --flake .#$DOTF_HOSTNAME --impure'

# Modern tools aliases
alias l="eza --header --long --git --group-directories-first --group --icons --color=always --sort=name --hyperlink -o --no-permissions"
alias ll='l'
alias la='l -a'
alias cat='bat'
alias du='dust'
alias df='duf'
alias rm="echo Use 'rip' instead of rm."

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
alias ddpul='docker compose down && docker compose pull && docker compose up -d && docker compose logs -f'

# Git aliases
alias g='git'
alias gg='git pull'
alias gp='git push'
alias gs='git status -s'
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'

# netstat port in use check
alias port='netstat -atupn | grep LISTEN'

# Alias for ls to l but only if it's an interactive shell because we don't want to override ls in scripts which could blow up in our face
if [ -t 1 ]; then
    alias ls='l'
fi

# Alias for ssh.exe and ssh-add.exe on Windows WSL (microsoft-standard-WSL2)
if [[ $(uname -a) == *"microsoft-standard-WSL2"* ]]; then
    alias op='op.exe'
fi

# PATH Manipulation
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/dotfiles/bin

# Add flatpak to XDG_DATA_DIRS
export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share

# Allow unfree nixos
export NIXPKGS_ALLOW_UNFREE=1

# Set DOTF_HOSTNAME to the hostname from .hostname file
# If this file doesn't exist, use mennos-unknown-hostname
export DOTF_HOSTNAME="mennos-unknown-hostname"
if [ -f $HOME/.hostname ]; then
    export DOTF_HOSTNAME=$(cat $HOME/.hostname)
fi

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

# Initialize starship if available
if ! command -v starship &> /dev/null; then
    echo "FYI, starship not found"
else
    eval "$(starship init bash)"
fi

# Source nix home-manager
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
fi

# Source agent-bridge script for 1password
source $HOME/dotfiles/bin/1password-agent-bridge.sh

# zoxide if available
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi

# Check if we are running from zellij, if not then launch it
launch_zellij_conditionally() {
    if [ -z "$ZELLIJ" ]; then
        # Don't launch zellij in tmux, vscode, screen or zeditor.
        if [ ! -t 1 ] || [ -n "$TMUX" ] || [ -n "$VSCODE_STABLE" ] || [ -n "$STY" ] || [ -n "$ZED_TERM" ]; then
            return
        fi

        # Launch zellij
        zellij

        # Exit if zellij exits properly with a zero exit code
        if [ $? -eq 0 ]; then
            exit $?
        fi

        echo "Zellij exited with a non-zero exit code, falling back to regular shell."
        return
    fi
}

# launch_zellij_conditionally

# Display a welcome message for interactive shells
if [ -t 1 ]; then
    dotf term
fi
