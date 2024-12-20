source $HOME/dotfiles/bin/helpers/functions.sh
export SSH_AUTH_SOCK=$HOME/.1password/agent.sock

# Check if is_wsl function returns true, don't continue if we are not on WSL
if ! is_wsl; then
    return
fi

printfe "%s" "cyan" "Running in WSL, ensuring 1Password SSH-Agent relay is running..."
ALREADY_RUNNING=$(ps -auxww | grep -q "[n]piperelay.exe -ei -s //./pipe/openssh-ssh-agent"; echo $?)
if [[ $ALREADY_RUNNING != "0" ]]; then
    if [[ -S $SSH_AUTH_SOCK ]]; then
        rm $SSH_AUTH_SOCK
    fi

    (setsid socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork EXEC:"npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
    printfe "%s\n" "green" " [ Started ]"
    exit 0
fi

printfe "%s\n" "green" " [ Already running ]"
