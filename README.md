# nirucon-suckless-modscript

Minimal script with a few functions for modifying Suckless software configurations, created by Nicklas Rudolfsson. This script allows for the easy customization of font size and font type in the DWM, ST, and DMENU configurations.

## Features

- Change font in DWM, ST, DMENU
- Change font size in DWM, ST, DMENU

## Usage

1. **Run the script**:
   ```bash
   ./nirucon-suckless-modscript.sh
   ```

2. **Follow the prompts**:
   - The script will display system information and the current installation status of DWM, ST, and DMENU.
   - You will be asked to enter the path to your Suckless main directory (default is `~/.config/suckless`).
   - Select which software to modify (DWM, ST, or DMENU).

3. **Modify font or font size**:
   - The script will display the current font and size.
   - Choose to change either the font or the font size.
   - Follow the prompts to input the new font or size.

4. **Rebuild the configuration**:
   - The script will update the `config.def.h` / `config.h` files and run `make clean install` to apply changes.
   - You need to restart the modified software for changes to take effect.

5. **Repeat or exit**:
   - After modification, you can choose to run the script again or exit.

## Requirements

- DWM, ST, or DMENU installed
- `make` and `sudo` permissions

## Notes

- This script is intended for personal use and might evolve in the future.

## License

Feel free to use and modify. Donations are welcome: [Donate via PayPal](https://www.paypal.com/paypalme/nicklasrudolfsson).
