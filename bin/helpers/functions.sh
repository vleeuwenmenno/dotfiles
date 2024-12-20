#!/usr/bin/env bash

#Color print function, usage: println "message" "color"
println() {
    color=$2
    printfe "%s\n" $color "$1"
}

is_wsl() {
    if [ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]; then
        return 0
    else
        return 1
    fi
}

logo() {
    echo "Menno's Dotfiles" | figlet | lolcat

    if [[ $(trash-list | wc -l) -gt 0 ]]; then
        printfe "%s" "yellow" "[!] $(trash-list | wc -l | tr -d ' ') file(s) in trash - "
    fi

    # Print if repo is dirty and the count of untracked files, modified files and staged files
    if [[ $(git -C ~/dotfiles status --porcelain) ]]; then
        printfe "%s" "yellow" "dotfiles is dirty "
        printfe "%s" "red" "[$(git -C ~/dotfiles status --porcelain | grep -c '^??')] untracked "
        printfe "%s" "yellow" "[$(git -C ~/dotfiles status --porcelain | grep -c '^ M')] modified "
        printfe "%s" "green" "[$(git -C ~/dotfiles status --porcelain | grep -c '^M ')] staged "
    fi

    printfe "%s" "blue" "[$(git -C ~/dotfiles rev-parse --short HEAD)] "
    if [[ $(git -C ~/dotfiles log origin/master..HEAD) ]]; then
        printfe "%s" "yellow" "[!] You have $(git -C ~/dotfiles log origin/master..HEAD --oneline | wc -l | tr -d ' ') commit(s) to push"
    fi

    println "" "normal"
}

# print colored with printf (args: format, color, message ...)
printfe() {
    format=$1
    color=$2
    shift 2

    red=$(tput setaf 1)
    green=$(tput setaf 2)
    yellow=$(tput setaf 3)
    blue=$(tput setaf 4)
    magenta=$(tput setaf 5)
    cyan=$(tput setaf 6)
    normal=$(tput sgr0)

    case $color in
    "red")
        color=$red
        ;;
    "green")
        color=$green
        ;;
    "yellow")
        color=$yellow
        ;;
    "blue")
        color=$blue
        ;;
    "magenta")
        color=$magenta
        ;;
    "cyan") 
        color=$cyan
        ;;
    *)
        color=$normal
        ;;
    esac

    printf "$color$format$normal" "$@"
}

ensure_package_installed() {
    if ! command -v $1 &>/dev/null; then
        println "$1 is not installed. Please install it." "red"
        exit 1
    fi
    println "   - $1 is available." "green"
}

ensure_sudo_privileges() {
    if sudo -n true 2>/dev/null; then 
        return
    else
        println "$1" "yellow"
        sudo true
    fi
}

function exesudo ()
{
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
    #
    # LOCAL VARIABLES:
    #
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
    
    #
    # I use underscores to remember it's been passed
    local _funcname_="$1"
    
    local params=( "$@" )               ## array containing all params passed here
    local tmpfile="/dev/shm/$RANDOM"    ## temporary file
    local content                       ## content of the temporary file
    local regex                         ## regular expression
    
    
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
    #
    # MAIN CODE:
    #
    ### ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ##
    
    #
    # WORKING ON PARAMS:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    #
    # Shift the first param (which is the name of the function)
    unset params[0]              ## remove first element
    # params=( "${params[@]}" )     ## repack array
    
    
    #
    # WORKING ON THE TEMPORARY FILE:
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    content="#!/bin/bash\n\n"
    
    #
    # Write the params array
    content="${content}params=(\n"
    
    regex="\s+"
    for param in "${params[@]}"
    do
        if [[ "$param" =~ $regex ]]
            then
                content="${content}\t\"${param}\"\n"
            else
                content="${content}\t${param}\n"
        fi
    done
    
    content="$content)\n"
    echo -e "$content" > "$tmpfile"
    
    #
    # Append the function source
    echo "#$( type "$_funcname_" )" >> "$tmpfile"
    
    #
    # Append the call to the function
    echo -e "\n$_funcname_ \"\${params[@]}\"\n" >> "$tmpfile"
    

    #
    # DONE: EXECUTE THE TEMPORARY FILE WITH SUDO
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    sudo bash "$tmpfile"
    rm "$tmpfile"
}

resolve_path() {
    echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

check_or_make_symlink() {
    source /home/menno/dotfiles/bin/helpers/functions.sh

    SOURCE="$1"
    TARGET="$2"

    # Take any ~ and replace it with $HOME
    SOURCE="${SOURCE/#\~/$HOME}"
    TARGET="${TARGET/#\~/$HOME}"

    # Ensure the parent directory of the target exists
    mkdir -p "$(dirname "$TARGET")"

    # if source doesn't exist it's likely a secret that hasn't been decrypted yet
    if [ ! -e "$SOURCE" ]; then
        printfe "%s\n" "yellow" "    - Source $SOURCE doesn't exist"
        return
    fi

    SOURCE=$(resolve_path "$SOURCE")
    TARGET=$(resolve_path "$TARGET")

    # Check if we have permissions to create the symlink
    if [ ! -w "$(dirname "$TARGET")" ]; then
        # Check if link exists
        if [ -L "$TARGET" ]; then
            # Check if it points to the correct location
            if [ "$(readlink "$TARGET")" != "$SOURCE" ]; then
                exesudo check_or_make_symlink "$SOURCE" "$TARGET"
                return
            fi
        else
            # Link doesn't exist but we don't have permissions to create it, so we should try to create it with sudosudo
            exesudo check_or_make_symlink "$SOURCE" "$TARGET"
        fi
        return
    fi

    # If target is already a symlink, we should check if it points to the correct location
    if [ -L "$TARGET" ]; then
        if [ "$(readlink "$TARGET")" != "$SOURCE" ]; then
            printfe "%s\n" "yellow" "    - Symlink $TARGET exists but points to the wrong location"
            printfe "%s\n" "yellow" "      Expected: $SOURCE"
            printfe "%s\n" "yellow" "      Actual: $(readlink "$TARGET")"
            printfe "%s\n" "yellow" "      Fixing symlink"
            rm "$TARGET"
            mkdir -p "$(dirname "$TARGET")"
            ln -s "$SOURCE" "$TARGET"
            printfe "%s\n" "green" "      Created symlink $TARGET -> $SOURCE"
            return
        fi
    fi

    # If target is a file and it's not a symlink, we should back it up
    if [ -f "$TARGET" ] && [ ! -L "$TARGET" ]; then
        printfe "%s\n" "yellow" "    - File $TARGET exists, backing up and creating symlink"
        mv "$TARGET" "$TARGET.bak"
    fi

    # If the target is already a symlink, and it points to the correct location, we should return and be happy
    if [ -L "$TARGET" ]; then
        printfe "%s" "green" "    - OK: "
        printfe "%-30s" "blue" "$SOURCE"
        printfe "%s" "cyan" " -> "
        printfe "%-30s\n" "blue" "$TARGET"
        return
    fi

    # Create the symlink
    mkdir -p "$(dirname "$TARGET")"
    ln -s "$SOURCE" "$TARGET"

    # Check if the symlink was created successfully
    if [ ! -L "$TARGET" ]; then
        printfe "%s\n" "red" "    - Failed to create symlink $TARGET -> $SOURCE"
        return
    fi

    printfe "%s" "green" "    - Added new symlink: "
    printfe "%-30s" "blue" "$SOURCE"
    printfe "%s" "cyan" " -> "
    printfe "%-30s\n" "blue" "$TARGET"
}

clear_line() {
    echo -en "\r"
}