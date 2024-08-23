#!/usr/bin/env zsh

source ~/dotfiles/bin/helpers/functions.sh
source ~/dotfiles/bin/lists/fonts.sh

install_font() {
    font_url="$1"
    font_name="$2"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        font_dir="$HOME/Library/Fonts"
    else
        font_dir="$HOME/.local/share/fonts"
    fi

    mkdir -p $font_dir

    # Check if any font files with the base name exist in the target directory
    found=$(find "$font_dir" -name "${font_name}*.ttf" | wc -l)
    if [ $found -gt 0 ]; then
        printfe "%s\n" "green" "    - $font_name is already installed"
    else
        printfe "%s" "yellow" "    - Downloading $font_name..."
        echo -en "\r"

        result=$(curl -s -L -w "%{http_code}" -o /tmp/$font_name.zip $font_url)
        if [ $? -ne 0 ] || [ "$result" -ne "200" ]; then
            printfe "%s\n" "red" "    - Failed to download $font_name"
            printfe "%s\n" "red" "      HTTP status code: $result"
            return 1
        fi

        printfe "%s" "yellow" "    - Unzipping $font_name..."
        echo -en "\r"

        result=$(unzip -o /tmp/$font_name.zip -d /tmp/$font_name 2>&1)
        if [ $? -ne 0 ]; then
            printfe "%s\n" "red" "    - Failed to unzip $font_name"
            printfe "%s\n" "red" "      Error: $result"
            return 1
        fi

        printfe "%s\n" "yellow" "    - Moving $font_name to $font_dir..."
        mv /tmp/$font_name/*.ttf $font_dir &> /dev/null

        # Clear font cache
        if [[ "$OSTYPE" != "darwin"* ]]; then
            fc-cache -fv $font_dir &> /dev/null
        fi

        printfe "%s\n" "green" "    - $font_name has been installed"
    fi
}

ensure_fonts_installed() {
    for font in "${fonts[@]}"; do
        install_font $(echo $font | awk '{print $1}') $(echo $font | awk '{print $2}')
    done
}

print_fonts_status() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        font_dir="$HOME/Library/Fonts"
    else
        font_dir="$HOME/.local/share/fonts"
    fi

    mkdir -p $font_dir

    total_fonts=0
    installed_fonts=0

    for font in "${fonts[@]}"; do
        font_name=$(echo $font | awk '{print $2}')
        ((total_fonts++))

        found=$(find "$font_dir" -name "${font_name}*.ttf" | wc -l)
        if [ "$found" -gt 0 ]; then
            ((installed_fonts++))
        fi
    done

    printfe "%s" "cyan" "NerdFonts:"
    if [ "$installed_fonts" -eq "$total_fonts" ]; then
        printfe "%s" "green" " $installed_fonts/$total_fonts "
    else
        printfe "%s" "red" " $installed_fonts/$total_fonts "
    fi
    printfe "%s\n" "cyan" "fonts installed"
}
