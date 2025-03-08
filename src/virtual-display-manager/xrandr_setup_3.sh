#!/bin/bash

# Run the initial xrandr setup script to reset display settings
# (disconnecting all displays except Virtual-1)
./xrandr_setup_1.sh

# Add modes for Virtual-2 and Virtual-3 with resolution 1920x1080
xrandr --addmode Virtual-2 1920x1080
xrandr --addmode Virtual-3 1920x1080

# Set the framebuffer to support 5760x1080 (three 1920x1080 displays)
xrandr --fb 5760x1080 --output Virtual-1 --panning 1920x1080/5760x1080

# Position Virtual-2 to the right of Virtual-1
xrandr --output Virtual-2 --mode 1920x1080 --right-of Virtual-1

# Position Virtual-3 to the right of Virtual-2
xrandr --output Virtual-3 --mode 1920x1080 --right-of Virtual-2
