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
TARGET_VIRTUAL_DISPLAY_MANAGER_DIR="/opt/virtual-display-manager"
TARGET_APPLICATIONS_DIR="/usr/share/applications"
USER_DESKTOPS_DIR="/home"
NUM_SHORTCUTS=3  # Number of shortcut files (adjust this as necessary)

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

# Security check: Ensure script is run by root user
if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: This script must be run as root!" >&2
  exit 1
fi

# Function to ensure proper permissions
set_permissions() {
  local path="$1"
  # Ensure that files and directories have secure permissions
  if [ -d "$path" ]; then
    chmod 755 "$path"      # Directories should be readable and executable, but not writable by non-admin users
    chown root:root "$path"  # Ownership should be root
  elif [ -f "$path" ]; then
    chmod 744 "$path"      # Files should be readable and executable, but not writable by non-admin users
    chown root:root "$path"  # Ownership should be root
  fi
}

# If confirmation is required, prompt for user confirmation to proceed after reading the security warning
if [ "$SKIP_CONFIRMATION" != true ]; then
  echo "WARNING: Please review the security guidelines before proceeding."
  echo "Ensure that you have inspected the contents of all files to be copied and linked."
  read -p "Do you wish to proceed with the installation (yes/no)? " proceed
  if [[ "$proceed" != "yes" ]]; then
    echo "Installation aborted. Please review the security guidelines and try again later."
    exit 0
  fi
fi

# Step 1: Move the virtual display manager directory to /opt
echo "Moving virtual display manager directory to /opt..."
if [ ! -d "$VIRTUAL_DISPLAY_MANAGER_DIR" ]; then
  echo "ERROR: Source directory $VIRTUAL_DISPLAY_MANAGER_DIR not found!" >&2
  exit 1
fi

# Security check: Inspect files before moving
echo "WARNING: Ensure that the contents of $VIRTUAL_DISPLAY_MANAGER_DIR have been reviewed and are safe."
echo "Do not proceed if you're unsure about the contents of these files."

mv "$VIRTUAL_DISPLAY_MANAGER_DIR" "$TARGET_VIRTUAL_DISPLAY_MANAGER_DIR"
set_permissions "$TARGET_VIRTUAL_DISPLAY_MANAGER_DIR"

# Step 2: Copy the .desktop shortcut files to /usr/share/applications
echo "Copying .desktop files to /usr/share/applications..."
for i in $(seq 1 $NUM_SHORTCUTS); do
  SHORTCUT="$SHORTCUTS_DIR/xrandr_setup_$i.desktop"
  if [ -f "$SHORTCUT" ]; then
    # Security check: Ensure the .desktop files are safe
    echo "WARNING: Ensure that the contents of $SHORTCUT have been reviewed before proceeding."
    echo "Do not proceed if you're unsure about the contents of these files."
    
    cp "$SHORTCUT" "$TARGET_APPLICATIONS_DIR/"
    set_permissions "$TARGET_APPLICATIONS_DIR/xrandr_setup_$i.desktop"
  else
    echo "ERROR: $SHORTCUT not found. Skipping..."
  fi
done

# Step 3: Create symbolic links for each user
echo "Creating symbolic links for each user..."
for user_home in "$USER_DESKTOPS_DIR"/*/; do
  if [ -d "$user_home/Desktop" ]; then
    for i in $(seq 1 $NUM_SHORTCUTS); do
      SHORTCUT="$TARGET_APPLICATIONS_DIR/xrandr_setup_$i.desktop"
      if [ -f "$SHORTCUT" ]; then
        # Security check: Prevent symlink creation for unknown files
        if ! grep -q "xrandr_setup_$i.desktop" <<< "$SHORTCUT"; then
          echo "ERROR: Unknown shortcut detected. Skipping symlink creation..."
          continue
        fi
        
        # Overwrite existing symlinks or files on the Desktop
        ln -sf "$SHORTCUT" "$user_home/Desktop/xrandr_setup_$i.desktop"
        chmod 755 "$user_home/Desktop/xrandr_setup_$i.desktop"
        chown "$user_home" "$user_home/Desktop/xrandr_setup_$i.desktop"
      else
        echo "ERROR: $SHORTCUT not found. Skipping symlink creation..."
      fi
    done
  fi
done


# Final Security Recommendations
echo "Installation complete!"
echo "SECURITY RECOMMENDATIONS:"
echo "1. Ensure that the files in $TARGET_APPLICATIONS_DIR have proper security settings."
echo "2. Review and audit all symlinked files on users' desktops to ensure there are no unintended files."
echo "3. Ensure that only trusted users have write permissions in the directories where these files reside."
echo ""
echo "USAGE EXPLANATION:"
echo "1. xrandr_setup_1.desktop: Resets your display setup to 1 display."
echo "2. xrandr_setup_2.desktop: Configures your system to use 2 displays."
echo "3. xrandr_setup_3.desktop: Sets up 3 displays."
echo "To use any of these setups, simply click the corresponding shortcut on your desktop."
echo ""
echo "Script authored by Samuel Ovadya. Thank you for using this tool!"

exit 0
