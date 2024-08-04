#!/bin/bash

# nirucon-suckless-modscript v0.1
# Minimal script with a few functions, might evolve in the future...
# Made by and for myself, Nicklas Rudolfsson https://github.com/nirucon

echo "Welcome to nirucon-suckless-modscript v0.1"
echo "Minimal script with a few functions, might evolve in the future..."
echo "Made by and for myself, Nicklas Rudolfsson https://github.com/nirucon"
echo ""
echo "Functional features:"
echo "- Change font size in dwm, st, dmenu"
echo "- More might be added :)"
echo ""

# Function to get OS name
get_os_name() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $NAME
    else
        uname -s
    fi
}

# Check and display system info
echo "You are running: $(get_os_name)"
echo "DWM: $(command -v dwm >/dev/null 2>&1 && echo "installed" || echo "not installed")"
echo "ST: $(command -v st >/dev/null 2>&1 && echo "installed" || echo "not installed")"
echo "DMENU: $(command -v dmenu >/dev/null 2>&1 && echo "installed" || echo "not installed")"
echo ""

# Ask for path-to-suckless directory
while true; do
    read -p "Enter your path to suckless main dir (default: ~/.config/suckless): " suckless_dir
    suckless_dir=${suckless_dir:-~/.config/suckless}

    if [ -d "$suckless_dir" ]; then
        break
    else
        echo "Error: Directory does not exist. Please try again."
    fi
done

# Ask what to mod
while true; do
    read -p "What do you want to mod? (DWM/ST/DMENU): " mod_choice
    mod_choice=$(echo "$mod_choice" | tr '[:upper:]' '[:lower:]')

    if [[ "$mod_choice" == "dwm" || "$mod_choice" == "st" || "$mod_choice" == "dmenu" ]]; then
        break
    else
        echo "Error: Please choose DWM, ST, or DMENU."
    fi
done

# Function to get current font and size from config.def.h
get_font_info() {
    local config_file=$1
    case $mod_choice in
        dwm)
            font_name=$(grep -Eo 'static const char \*fonts\[\] = \{ "[^:]+:size=[0-9]+' "$config_file" | sed 's/static const char \*fonts\[\] = \{ "//')
            font_size=$(echo "$font_name" | grep -Eo '[0-9]+')
            ;;
        st)
            font_name=$(grep -Eo 'static char \*font = "[^:]+:size=[0-9]+' "$config_file" | sed 's/static char \*font = "//')
            font_size=$(echo "$font_name" | grep -Eo '[0-9]+')
            ;;
        dmenu)
            font_name=$(grep -Eo 'static const char \*fonts\[\] = \{ "[^:]+:size=[0-9]+' "$config_file" | sed 's/static const char \*fonts\[\] = \{ "//')
            font_size=$(echo "$font_name" | grep -Eo '[0-9]+')
            ;;
    esac
}

# Function to change font size in config.def.h
change_font_size() {
    local config_file=$1
    read -p "Do you want to change the fontsize? Y/n: " change_font
    change_font=${change_font:-y}

    if [[ "$change_font" =~ ^[Yy]$ ]]; then
        read -p "Input new font size (only numbers) and press enter: " new_font_size
        new_font_name=$(echo "$font_name" | sed "s/[0-9]\+/$new_font_size/")
        case $mod_choice in
            dwm)
                sed -i "s|$font_name|$new_font_name|" "$config_file"
                ;;
            st)
                sed -i "s|$font_name|$new_font_name|" "$config_file"
                ;;
            dmenu)
                sed -i "s|$font_name|$new_font_name|" "$config_file"
                ;;
        esac
        cp "$config_file" "$(dirname "$config_file")/config.h"
        sudo make -C "$(dirname "$config_file")" clean install
        echo "Font size changed to $new_font_size. You may need to restart your $mod_choice."
    fi
}

# Determine config.def.h path based on choice
case $mod_choice in
    dwm)
        config_file=$(find "$suckless_dir" -name "config.def.h" -path "*/dwm/*")
        ;;
    st)
        config_file=$(find "$suckless_dir" -name "config.def.h" -path "*/st/*")
        ;;
    dmenu)
        config_file=$(find "$suckless_dir" -name "config.def.h" -path "*/dmenu/*")
        ;;
esac

# Get current font info
get_font_info "$config_file"

# Display current font info and prompt for changes
echo "$mod_choice"
echo "Font"
echo "Current font is: $font_name"
echo "Current font size is: $font_size"

change_font_size "$config_file"

# Ask to run the script again or quit
while true; do
    read -p "Do you want to run this modscript again? Y/n: " run_again
    run_again=${run_again:-y}
    if [[ "$run_again" =~ ^[Yy]$ ]]; then
        exec "$0"
    else
        echo "Bye!"
        exit 0
    fi
done
