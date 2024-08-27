#!/usr/bin/env zsh

source $HOME/dotfiles/bin/helpers/functions.sh

countdown() {
    for i in $(seq $1 -1 1); do
        printfe "%s" "green" "  - Waiting for $i seconds... "
        echo -en "\r"
        sleep 1
    done
}

run_startup_scripts() {
    # Initialize array to hold commands
    local startup_commands=()
    
    # Read each command key and add it to the array
    while IFS= read -r command; do
        startup_commands+=("$command")
    done < <(cat $HOME/dotfiles/config/config.yaml | shyaml keys config.startup.commands)

    # Read delay and delay_between_ms values from YAML
    local delay=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.startup.delay)
    local delay_between_ms=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.startup.delay_between_ms)

    printfe "%s\n" "cyan" "Running startup commands... (delay: $delay s, delay_between: $delay_between_ms ms)"
    
    # Wait for the initial delay
    countdown $delay

    # Execute each command in a new screen window
    for command_key in "${startup_commands[@]}"; do
        local command=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.startup.commands.$command_key)

        printfe "%s" "green" "  - Running '"
        printfe "%s" "blue" "$command_key"
        printfe "%s" "green" "'... ("
        printfe "%s" "blue" "$command"
        printfe "%s\n" "green" ")"
        
        # Run the command in a new screen session named after the command_key
        screen -dmS $command_key zsh -c "eval $command"

        # Wait for the delay between commands
        sleep $(echo "scale=2; $delay_between_ms / 1000" | bc)
    done
}

# Check if we're in a graphical session
if [[ -z "$DISPLAY" && "$XDG_SESSION_TYPE" != "x11" && "$XDG_SESSION_TYPE" != "wayland" ]]; then
    echo "Not in a graphical session. Exiting."
    exit 0
fi

run_startup_scripts

# Show message to press any key to close the terminal window
printfe "%s" "green" "Press any key to close this window..."
read -s -n 1
exit 0
