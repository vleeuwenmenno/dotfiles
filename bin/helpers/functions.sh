#!/usr/bin/env zsh

#Color print function, usage: println "message" "color"
println() {
    color=$2
    printfe "%s\n" $color "$1"
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

ask_before_do() {
    printfe "%s" "yellow" "Trying to run: "
    printfe "%s" "cyan" "'$@' "
    read -p "Continue? [y/N]: " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return
    fi

    printfe "%s" "cyan" "Running '"
    printfe "%s" "yellow" "$@"
    println "'..." "cyan"

    # In case DRY_RUN is set to true we should just print the command and not run it
    if [ "$DRY_RUN" = true ]; then
        println "Would have run '$@'" "yellow"
        return
    else
        $@
    fi
}

ensure_sudo_privileges() {
    if sudo -n true 2>/dev/null; then 
        return
    else
        println "$1" "yellow"
        sudo true
    fi
}

ask_before_do_multi() {
    if [ "$DRY_RUN" = true ]; then
        println "Would have run: $1" "yellow"
    else
        read -p "$1 (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return false
        fi
        return true
    fi
}

add_to_hosts() {
    local domain=$1
    local ip="127.0.0.1"

    # Check if domain already exists in /etc/hosts
    if ! grep -q "$domain" /etc/hosts; then
        println "   - adding $domain to /etc/hosts" "yellow"
        echo "$ip $domain" | sudo tee -a /etc/hosts >/dev/null
    else
        println "   - $domain already exists in /etc/hosts" "green"
    fi
}

# Function to check if $1 is a path to a symlink, if not it will make a symlink to $2
# In case there's a file at the location of the symlink, it will backup the file
# Parameters
# $1: file to check
# $2: link location
check_or_make_symlink() {
    if [ ! -L $1 ]; then
        if [ -f $1 ]; then
            mv $1 $1.bak
            printfe "%s\n" "yellow" "Backed up $1 to $1.bak"
        fi
        ln -s $2 $1
        printfe "%s\n" "green" "Created symlink $1 -> $2"
    fi

    # Confirm the symlink that already exists point to the correct location
    if [ -L $1 ]; then
        if [ "$(readlink $1)" != $2 ]; then
            printfe "%s\n" "yellow" "Symlink $1 exists but points to the wrong location"
            printfe "%s\n" "yellow" "Expected: $2"
            printfe "%s\n" "yellow" "Actual: $(readlink $1)"
            printfe "%s\n" "yellow" "Fixing symlink"
            rm $1
            ln -s $2 $1
            printfe "%s\n" "green" "Created symlink $1 -> $2"
        fi
    fi
}