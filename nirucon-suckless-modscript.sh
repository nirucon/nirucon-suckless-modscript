#!/bin/bash

# nirucon-suckless-modscript v0.1
# Minimal script with a few functions, might evolve in the future...
# Made by and for myself, Nicklas Rudolfsson https://github.com/nirucon

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

clear

# ASCII logo
cat << "EOF"
 _ _ 
( V )
 \ / 
  V
                                             
I Love Suckless!
EOF
echo "-------------------------------------------------------------------------------------"
echo -e "${CYAN}Welcome to nirucon-suckless-modscript v0.1${NC}"
echo "Minimal script with a few functions, might evolve in the future..."
echo -e "Made by and for myself, ${GREEN}Nicklas Rudolfsson${NC} https://github.com/nirucon"
echo ""
echo -e "${YELLOW}Functional features:${NC}"
echo "- Change font size in dwm, st, dmenu"
echo "- Change font in dwm, st, dmenu"
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
echo -e "You are running: ${GREEN}$(get_os_name)${NC}"
echo -e "DWM: $(command -v dwm >/dev/null 2>&1 && echo -e "${GREEN}installed${NC}" || echo -e "${RED}not installed${NC}")"
echo -e "ST: $(command -v st >/dev/null 2>&1 && echo -e "${GREEN}installed${NC}" || echo -e "${RED}not installed${NC}")"
echo -e "DMENU: $(command -v dmenu >/dev/null 2>&1 && echo -e "${GREEN}installed${NC}" || echo -e "${RED}not installed${NC}")"
echo ""

# Ask for path-to-suckless directory
while true; do
    read -p "Enter your path to suckless main dir (default: ~/.config/suckless): " suckless_dir
    suckless_dir=${suckless_dir:-~/.config/suckless}

    if [ -d "$suckless_dir" ]; then
        break
    else
        echo -e "${RED}Error: Directory does not exist. Please try again.${NC}"
    fi
done

# Ask what to mod
while true; do
    read -p "What do you want to mod? (DWM/ST/DMENU): " mod_choice
    mod_choice=$(echo "$mod_choice" | tr '[:upper:]' '[:lower:]')

    if [[ "$mod_choice" == "dwm" || "$mod_choice" == "st" || "$mod_choice" == "dmenu" ]]; then
        break
    else
        echo -e "${RED}Error: Please choose DWM, ST, or DMENU.${NC}"
    fi
done

# Function to get current font and size from config.def.h
get_font_info() {
    local config_file=$1
    case $mod_choice in
        dwm)
            font_line=$(grep -E 'static const char \*fonts\[\] = \{ "[^"]+' "$config_file")
            font_name=$(echo "$font_line" | sed -E 's/static const char \*fonts\[\] = \{ "([^:]+):size=[0-9]+.*/\1/')
            font_size=$(echo "$font_line" | grep -o 'size=[0-9]\+' | grep -o '[0-9]\+')
            ;;
        st)
            font_line=$(grep -E 'static char \*font = "[^"]+' "$config_file")
            font_name=$(echo "$font_line" | sed -E 's/static char \*font = "([^:]+):size=[0-9]+.*/\1/')
            font_size=$(echo "$font_line" | grep -o 'size=[0-9]\+' | grep -o '[0-9]\+')
            ;;
        dmenu)
            font_line=$(grep -E 'static const char \*fonts\[\] = \{ "[^"]+' "$config_file")
            font_name=$(echo "$font_line" | sed -E 's/static const char \*fonts\[\] = \{ "([^:]+):size=[0-9]+.*/\1/')
            font_size=$(echo "$font_line" | grep -o 'size=[0-9]\+' | grep -o '[0-9]\+')
            ;;
    esac
}

# Function to change font size in config.def.h
change_font_size() {
    local config_file=$1
    read -p "Input new font size (only numbers) and press enter to keep current size ($font_size): " new_font_size
    new_font_size=${new_font_size:-$font_size}
    new_font_name="$font_name:size=$new_font_size"
    case $mod_choice in
        dwm)
            sed -i "s|$font_name:size=[0-9]\+|$new_font_name|" "$config_file"
            ;;
        st)
            sed -i "s|$font_name:size=[0-9]\+|$new_font_name|" "$config_file"
            ;;
        dmenu)
            sed -i "s|$font_name:size=[0-9]\+|$new_font_name|" "$config_file"
            ;;
    esac
    cp "$config_file" "$(dirname "$config_file")/config.h"
    echo -e "Running ${CYAN}sudo make clean install${NC} in $(dirname "$config_file")"
    sudo make -C "$(dirname "$config_file")" clean install
    echo -e "Font size changed to ${GREEN}$new_font_size${NC}. You may need to restart your $mod_choice."
}

# Function to search for available fonts
search_fonts() {
    fc-list : family | sort -u | sed 's/,.*$//'
}

# Function to filter fonts based on user input
filter_fonts() {
    local input=$1
    local fonts=("$@")
    local filtered_fonts=()
    for font in "${fonts[@]:1}"; do
        if [[ "$font" == *"$input"* ]]; then
            filtered_fonts+=("$font")
        fi
    done
    echo "${filtered_fonts[@]}"
}

# Function to change the font
change_font() {
    local config_file=$1
    local available_fonts=($(search_fonts))
    local filtered_fonts=()

    while true; do
        read -p "Start typing the font name and press Enter: " font_input
        filtered_fonts=($(filter_fonts "$font_input" "${available_fonts[@]}"))

        if [ ${#filtered_fonts[@]} -eq 0 ]; then
            echo -e "${RED}No matching fonts found. Please try again.${NC}"
        else
            break
        fi
    done

    echo "Matching fonts:"
    for i in "${!filtered_fonts[@]}"; do
        printf "%3d) %s\n" $((i + 1)) "${filtered_fonts[$i]}"
    done

    while true; do
        read -p "Enter the number of the font you want to use: " font_choice
        if [[ "$font_choice" =~ ^[0-9]+$ ]] && ((font_choice > 0 && font_choice <= ${#filtered_fonts[@]})); then
            new_font_name="${filtered_fonts[$((font_choice - 1))]}"
            break
        else
            echo -e "${RED}Invalid choice. Please try again.${NC}"
        fi
    done

    read -p "Input new font size (only numbers) and press enter, or just press enter to keep current size ($font_size): " new_font_size
    new_font_size=${new_font_size:-$font_size}
    new_font_string="$new_font_name:size=$new_font_size:antialias=true:autohint=true"

    case $mod_choice in
        dwm)
            sed -i "s|static const char \*fonts\[\] = \{ \".*\"|static const char \*fonts\[\] = \{ \"$new_font_string\"|" "$config_file"
            sed -i "s|static const char dmenufont\[\] = \".*\"|static const char dmenufont\[\] = \"$new_font_string\"|" "$config_file"
            ;;
        st)
            sed -i "s|static char \*font = \".*\"|static char \*font = \"$new_font_string\"|" "$config_file"
            ;;
        dmenu)
            sed -i "s|static const char \*fonts\[\] = \{ \".*\"|static const char \*fonts\[\] = \{ \"$new_font_string\"|" "$config_file"
            ;;
    esac

    cp "$config_file" "$(dirname "$config_file")/config.h"
    echo -e "Running ${CYAN}sudo make clean install${NC} in $(dirname "$config_file")"
    sudo make -C "$(dirname "$config_file")" clean install
    echo -e "Font changed to ${GREEN}$new_font_string${NC}. You may need to restart your $mod_choice."
}

# Determine config.def.h path based on choice
case $mod_choice in
    dwm)
        config_file=$(find "$suckless_dir" -iname "config.def.h" -path "*/dwm*" | head -n 1)
        ;;
    st)
        config_file=$(find "$suckless_dir" -iname "config.def.h" -path "*/st*" | head -n 1)
        ;;
    dmenu)
        config_file=$(find "$suckless_dir" -iname "config.def.h" -path "*/dmenu*" | head -n 1)
        ;;
esac

if [ -z "$config_file" ]; then
    echo -e "${RED}Error: Could not find config.def.h for $mod_choice in $suckless_dir${NC}"
    exit 1
fi

# Get current font info
get_font_info "$config_file"

# Display current font info and prompt for changes
echo -e "${CYAN}$mod_choice${NC}"
echo "Font"
echo -e "Current font is: ${GREEN}$font_name${NC}"
echo -e "Current font size is: ${GREEN}$font_size${NC}"

# Prompt user to change font or font size
while true; do
    read -p "Do you want to change the font or the font size? (font/size): " change_choice
    change_choice=$(echo "$change_choice" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$change_choice" == "font" ]]; then
        change_font "$config_file"
        break
    elif [[ "$change_choice" == "size" ]]; then
        change_font_size "$config_file"
        break
    else
        echo -e "${RED}Error: Please choose 'font' or 'size'.${NC}"
    fi
done

# Ask to run the script again or quit
while true; do
    read -p "Do you want to run this modscript again? Y/n: " run_again
    run_again=${run_again:-y}
    if [[ "$run_again" =~ ^[Yy]$ ]]; then
        exec "$0"
    else
        echo -e "${CYAN}Bye!${NC}"
        exit 0
    fi
done
