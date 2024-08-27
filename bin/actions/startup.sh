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
    logo continue
    echo ""
    local time_of_day
    # Time of day (morning, afternoon, evening, night)
    case $(date +%H) in
        0[0-9]|1[0-1])
            time_of_day="morning"
            emoji="🌅"
            ;;
        1[2-7])
            time_of_day="afternoon"
            emoji="🌞"
            ;;
        1[8-9]|2[0-3])
            time_of_day="evening"
            emoji="🌆"
            ;;
    esac
    printfe "%s" "cyan" "Hi $(whoami), good $time_of_day! $emoji"
    echo ""

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

    # Ensure the log folder exists
    mkdir -p $HOME/dotfiles/logs/startup

    # Execute each command in a new screen window
    for command_key in "${startup_commands[@]}"; do
        local command=$(cat $HOME/dotfiles/config/config.yaml | shyaml get-value config.startup.commands.$command_key)

        printfe "%s" "green" "  - Running '"
        printfe "%s" "blue" "$command_key"
        printfe "%s" "green" "'... ("
        printfe "%s" "blue" "$command"
        printfe "%s\n" "green" ")"

        # Check if a screen with the same name already exists, if so log it and don't run the command
        if screen -list | grep -q $command_key; then
            printfe "%s" "red" "    - Screen session already exists: "
            printfe "%s" "blue" "$command_key"
            printfe "%s\n" "red" ""
            continue
        fi
        
        # Ensure the log file exists, if it exists, clear it
        touch $HOME/dotfiles/logs/startup/$command_key.log

        # Run the command in a new screen session named after the command_key
        screen -dmS $command_key zsh -c "eval $command > $HOME/dotfiles/logs/startup/$command_key.log 2>&1"
        sleep $(echo "scale=2; $delay_between_ms / 1000" | bc)

        if ! screen -list | grep -q $command_key; then
            printfe "%s" "red" "    - Screen session died immediately: "
            printfe "%s" "blue" "$command_key"
            printfe "%s\n" "red" " (Within $delay_between_ms ms, check the logs for more information in $HOME/dotfiles/logs/startup/$command_key.log)"
            continue
        fi

        # Check if command is ok, if not log that it failed
        if [ $? -ne 0 ]; then
            printfe "%s" "red" "    - Command failed: "
            printfe "%s" "blue" "$command"
            printfe "%s\n" "red" ""
        fi
    done
}

# Check if we're in a graphical session
if [[ -z "$DISPLAY" && "$XDG_SESSION_TYPE" != "x11" && "$XDG_SESSION_TYPE" != "wayland" ]]; then
    echo "Not in a graphical session. Exiting."
    exit 0
fi

run_startup_scripts

echo ""
printfe "%s" "green" "Something went wrong? Check the logs in $HOME/dotfiles/logs/startup/ for more information."
echo ""

# Show message to press any key to close the terminal window
printfe "%s\n" "green" "Press any key to close this window..."
read -s -n 1
exit 0
