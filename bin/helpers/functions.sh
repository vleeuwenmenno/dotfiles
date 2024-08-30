#!/usr/bin/env zsh

#Color print function, usage: println "message" "color"
println() {
    color=$2
    printfe "%s\n" $color "$1"
}

logo() {
    tput setaf 2
    cat $HOME/dotfiles/bin/resources/logo.txt
    println " " "cyan"
    tput sgr0

    # Print if repo is dirty and the count of untracked files, modified files and staged files
    if [[ $(git -C ~/dotfiles status --porcelain) ]]; then
        printfe "%s" "yellow" "dotfiles repo is dirty "
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

resolve_path() {
    echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

check_or_make_symlink() {
    SOURCE="$1"
    TARGET="$2"

    # Take any ~ and replace it with $HOME
    SOURCE="${SOURCE/#\~/$HOME}"
    TARGET="${TARGET/#\~/$HOME}"

    SOURCE=$(resolve_path "$SOURCE")
    TARGET=$(resolve_path "$TARGET")

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