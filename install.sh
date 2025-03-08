#!/bin/bash

# Author: Samuel Ovadya
# Security Guidelines:
# 1. NEVER run this script automatically or without reviewing the content of the files it is copying or linking.
# 2. Always manually inspect files like the `.desktop` and `.sh` files before running this script to ensure they are safe.
# 3. Ensure the files have the appropriate permissions to avoid security risks:
#    - Do not give write permissions to non-administrative users.
#    - Set executable permissions only for files that require execution.
# 4. Always run the script as root (but with caution) to ensure that the system files are modified appropriately.
# 5. Ensure the source files are from trusted sources. If the files have been modified by an untrusted party, they could compromise your system.

# Usage Explanation:
# The script includes shortcut files that are designed to set up different numbers of displays using xrandr.
# - `xrandr_setup_1.desktop` will reset your display setup to 1 display.
# - `xrandr_setup_2.desktop` will configure your system to use 2 displays.
# - `xrandr_setup_3.desktop` will set up 3 displays.
# These .desktop files are simple shortcuts that will execute corresponding shell scripts to configure the display setup.
#
# You can use these shortcuts by clicking them on your desktop. Make sure to manually review each of the .desktop files before running them.

# Define variables
VIRTUAL_DISPLAY_MANAGER_DIR="src/virtual-display-manager"
SHORTCUTS_DIR="src/shortcuts"
TARGET_VIRTUAL_DISPLAY_MANAGER_DIR="/opt/"
TARGET_APPLICATIONS_DIR="/usr/share/applications"
USER_DESKTOPS_DIR="/home"
NUM_SHORTCUTS=3  # Number of shortcut files (adjust this as necessary)

# Colors for printing
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'

# Parse command-line arguments
while getopts "y" opt; do
  case ${opt} in
    y)
      SKIP_CONFIRMATION=true
      ;;
    *)
      SKIP_CONFIRMATION=false
      ;;
  esac
done

# Preset to [Y/n] if SKIP_CONFIRMATION is not set
if [ "$SKIP_CONFIRMATION" = true ]; then
  echo "Skipping confirmation"
else
  read -p "Are you sure? [Y/n]: " response
  response=${response:-Y}  # Default to Y if no input is given
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi


# Security check: Ensure script is run by root user
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}ERROR: This script must be run as root! " >&2
  exit 1
fi

# If confirmation is required, prompt for user confirmation to proceed after reading the security warning
if [ "$SKIP_CONFIRMATION" != true ]; then
  read -p "${YELLOW}Do you wish to proceed with the installation [Y/n]? " proceed
  proceed=${proceed:-Y}  # Default to 'Y' if no input is given
  if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation aborted. Please review the security guidelines and try again later."
    exit 0
  fi
fi


# Step 1: Move the virtual display manager directory to /opt
echo -e "${BLUE}Moving virtual display manager directory to /opt/ "
if [ ! -d "$VIRTUAL_DISPLAY_MANAGER_DIR" ]; then
  echo -e "${RED}ERROR: Source directory $VIRTUAL_DISPLAY_MANAGER_DIR not found! " >&2
  exit 1
fi

cp -r "$VIRTUAL_DISPLAY_MANAGER_DIR" "$TARGET_VIRTUAL_DISPLAY_MANAGER_DIR"

# Set permissions for virtual display manager directory
chmod -R 755 "$TARGET_VIRTUAL_DISPLAY_MANAGER_DIR"
chown -R root:root "$TARGET_VIRTUAL_DISPLAY_MANAGER_DIR"
echo -e "${GREEN}Files moved to $TARGET_VIRTUAL_DISPLAY_MANAGER_DIR"

# Step 2: Copy the .desktop shortcut files to /usr/share/applications
echo -e "${BLUE}Copying .desktop files to /usr/share/applications/ "
for i in $(seq 1 $NUM_SHORTCUTS); do
  SHORTCUT="$SHORTCUTS_DIR/xrandr_setup_$i.desktop"
  if [ -f "$SHORTCUT" ]; then
    cp "$SHORTCUT" "$TARGET_APPLICATIONS_DIR/"
    
    # Set permissions for the .desktop files
    chmod 744 "$TARGET_APPLICATIONS_DIR/xrandr_setup_$i.desktop"
    chown root:root "$TARGET_APPLICATIONS_DIR/xrandr_setup_$i.desktop"
  else
    echo -e "${RED}ERROR: $SHORTCUT not found. Skipping... "
  fi
done
echo -e "${GREEN}Shortcuts moved to /usr/share/applications/"

# Step 3: Create symbolic links for each user
echo -e "${BLUE}Creating symbolic links for each user... "
for user_home in "$USER_DESKTOPS_DIR"/*/; do
  if [ -d "$user_home/Desktop" ]; then
    username=$(basename "$user_home")  # Extract username from the home directory path
    for i in $(seq 1 $NUM_SHORTCUTS); do
      SHORTCUT="$TARGET_APPLICATIONS_DIR/xrandr_setup_$i.desktop"
      if [ -f "$SHORTCUT" ]; then
        # Security check: Prevent symlink creation for unknown files
        if ! grep -q "xrandr_setup_$i.desktop" <<< "$SHORTCUT"; then
          echo -e "${RED}ERROR: Unknown shortcut detected. Skipping symlink creation... "
          continue
        fi
        
        # Overwrite existing symlinks or files on the Desktop
        ln -sf "$SHORTCUT" "$user_home/Desktop/xrandr_setup_$i.desktop"
        chmod 755 "$user_home/Desktop/xrandr_setup_$i.desktop"
      else
        echo -e "${RED}ERROR: $SHORTCUT not found. Skipping symlink creation... "
      fi
    done
  fi
done
echo -e "${GREEN}Symlinks created"


# Final Security Recommendations
echo -e "${GREEN}=$(printf '=%.0s' {1..36})"
echo -e "${GREEN}Installation complete! "
echo -e "${CYAN}SECURITY RECOMMENDATIONS: "
echo "1. Ensure that the files in $TARGET_APPLICATIONS_DIR have proper security settings."
echo "2. Review and audit all symlinked files on users' desktops to ensure there are no unintended files."
echo "3. Ensure that only trusted users have write permissions in the directories where these files reside."
echo ""
echo -e "${CYAN}USAGE EXPLANATION: "
echo "1. xrandr_setup_1.desktop: Resets your display setup to 1 display."
echo "2. xrandr_setup_2.desktop: Configures your system to use 2 displays."
echo "3. xrandr_setup_3.desktop: Sets up 3 displays."
echo "To use any of these setups, simply click the corresponding shortcut on your desktop."
echo ""
echo "Script authored by Samuel Ovadya. Thank you for using this tool!"

exit 0
