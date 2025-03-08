#!/bin/bash


TARGET_APPLICATIONS_DIR="/usr/share/applications"
TARGET_VIRTUAL_DISPLAY_MANAGER_DIR="/opt/virtual-display-manager"
USER_DESKTOPS_DIR="/home"
NUM_SHORTCUTS=3


# Security check: Ensure script is run by root user
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}ERROR: This script must be run as root!${RESET}" >&2
    exit 1
fi

rm -r "$TARGET_VIRTUAL_DISPLAY_MANAGER_DIR"

for i in $(seq 1 $NUM_SHORTCUTS); do
    rm "$TARGET_APPLICATIONS_DIR/xrandr_setup_$i.desktop"
    for user_home in "$USER_DESKTOPS_DIR"/*/; do
        if [ -d "$user_home/Desktop" ]; then
            username=$(basename "$user_home")  # Extract username from the home directory path
            rm "$user_home/Desktop/xrandr_setup_$i.desktop"
    done   
done

