k#!/bin/bash

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

# Function to handle user prompts
prompt_user() {
    local prompt_text=$1
    local allow_back=$2
    local allow_quit=$3
    local user_input

    while true; do
        read -p "$prompt_text" user_input
        if [ "$allow_quit" == "true" ] && [[ "$user_input" =~ ^([Qq]|quit)$ ]]; then
            echo -e "${CYAN}Bye!${NC}"
            exit 0
        elif [ "$allow_back" == "true" ] && [[ "$user_input" =~ ^([Bb]|back)$ ]]; then
            return 1
        else
            echo "$user_input"
            return 0
        fi
    done
}

# Main menu function
main_menu() {
    local step=0

    while true; do
        case $step in
            0) # Ask for path-to-suckless directory
                suckless_dir=$(prompt_user "Enter your path to suckless main dir and press enter or just press enter for default (~/.config/suckless): " false false)
                [ $? -eq 1 ] && continue
                suckless_dir=${suckless_dir:-~/.config/suckless}

                if [ -d "$suckless_dir" ]; then
                    step=1
                else
                    echo -e "${RED}Error: Directory does not exist. Please try again.${NC}"
                fi
                ;;

            1) # Ask what to mod
                mod_choice=$(prompt_user "What do you want to mod? (1=DWM, 2=ST, 3=DMENU, 4=Back, 5=Quit): " true false)
                case $mod_choice in
                    1) mod_choice="dwm"; step=2 ;;
                    2) mod_choice="st"; step=2 ;;
                    3) mod_choice="dmenu"; step=2 ;;
                    4) step=0 ;;
                    5) echo -e "${CYAN}Bye!${NC}"; exit 0 ;;
                    *) echo -e "${RED}Error: Please choose 1, 2, 3, 4, or 5.${NC}" ;;
                esac
                ;;

            2) # Determine config.def.h path based on choice
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
                    step=1
                else
                    step=3
                fi
                ;;

            3) # Get current font info
                get_font_info "$config_file"
                echo -e "${CYAN}$mod_choice${NC}"
                echo "Font"
                echo -e "Current font is: ${GREEN}$font_name${NC}"
                echo -e "Current font size is: ${GREEN}$font_size${NC}"
                step=4
                ;;

            4) # Prompt user to change font or font size
                change_choice=$(prompt_user "Do you want to change the font or the font size? (1=font, 2=size, 3=Back, 4=Quit): " true false)
                case $change_choice in
                    1) change_font "$config_file"; [ $? -eq 1 ] && step=4 || step=5 ;;
                    2) change_font_size "$config_file"; [ $? -eq 1 ] && step=4 || step=5 ;;
                    3) step=1 ;;
                    4) echo -e "${CYAN}Bye!${NC}"; exit 0 ;;
                    *) echo -e "${RED}Error: Please choose 1, 2, 3, or 4.${NC}" ;;
                esac
                ;;

            5) # Ask to run the script again or quit
                run_again=$(prompt_user "Do you want to run this modscript again? (Y/n): " false true)
                case $run_again in
                    [Yy]*|"") step=0 ;;
                    [Nn]*) echo -e "${CYAN}Bye!${NC}"; exit 0 ;;
                    *) echo -e "${RED}Error: Please choose Y or n.${NC}" ;;
                esac
                ;;
        esac
    done
}

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
    while true; do
        new_font_size=$(prompt_user "Input new font size (only numbers like: 10) and press enter to keep current size ($font_size): " true true)
        [ $? -eq 1 ] && return 1
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
        break
    done
}

# Function to search for available fonts and list them without file extensions or trailing characters
search_fonts() {
    local font_dirs=()
    [ -d /usr/share/fonts ] && font_dirs+=("/usr/share/fonts")
    [ -d /usr/local/share/fonts ] && font_dirs+=("/usr/local/share/fonts")
    [ -d ~/.local/share/fonts ] && font_dirs+=("$HOME/.local/share/fonts")

    find "${font_dirs[@]}" -type f \( -name "*.ttf" -o -name "*.otf" \) -print | while read -r font_file; do
        base_name=$(basename "$font_file" | sed 's/\.[ot]tf$//')
        echo "$base_name"
    done | sort -u
}

# Function to filter fonts based on user input (case-insensitive)
filter_fonts() {
    local input=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    local fonts=("${@:2}")
    local filtered_fonts=()
    for font in "${fonts[@]}"; do
        if [[ "$(echo "$font" | tr '[:upper:]' '[:lower:]')" =~ $input ]]; then
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
        font_input=$(prompt_user "Start typing the font name and press Enter: " true true)
        [ $? -eq 1 ] && return 1
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
        font_choice=$(prompt_user "Enter the number of the font you want to use: " true true)
        [ $? -eq 1 ] && return 1
        if [[ "$font_choice" =~ ^[0-9]+$ ]] && ((font_choice > 0 && font_choice <= ${#filtered_fonts[@]})); then
            new_font_name="${filtered_fonts[$((font_choice - 1))]}"
            break
        else
            echo -e "${RED}Invalid choice. Please try again.${NC}"
        fi
    done

    new_font_size=$(prompt_user "Input new font size (only numbers) and press enter to keep current size ($font_size): " true true)
    [ $? -eq 1 ] && return 1
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

# Start the main menu loop
main_menu
