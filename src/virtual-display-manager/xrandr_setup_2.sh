#!/bin/bash

# Run the initial xrandr setup script to reset display settings 
# (disconnecting all except Virtual-1 or the primary display)
./xrandr_setup_1.sh 

# Re-enable Virtual-2 with the desired resolution
xrandr --addmode Virtual-2 1920x1080 

# Set the framebuffer to accommodate both Virtual-1 and Virtual-2
xrandr --fb 3840x1080 --output Virtual-1 --pos 1920x0 --panning 1920x1080/3840x1080 

# Position Virtual-2 to the right of Virtual-1
xrandr --output Virtual-2 --mode 1920x1080 --right-of Virtual-1 

