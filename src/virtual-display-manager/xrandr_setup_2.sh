#!/bin/bash

echo "Running initial xrandr setup..."
./xrandr_setup_1.sh 

# Get the resolution of Virtual-1
resolution=$(xrandr | grep -w "Virtual-1" | grep -oP '\d+x\d+' | head -1)
width=$(echo "$resolution" | cut -d 'x' -f1)
height=$(echo "$resolution" | cut -d 'x' -f2)

# Check if we successfully retrieved the resolution
if [[ -z "$width" || -z "$height" ]]; then
    echo "Error: Failed to get resolution of Virtual-1"
    exit 1
fi

echo "Detected Virtual-1 resolution: ${width}x${height}"

# Calculate new framebuffer size (2x width of Virtual-1)
new_fb_width=$((width * 2))
new_fb_height=$height

echo "Calculated framebuffer size: ${new_fb_width}x${new_fb_height}"

# Add mode for Virtual-2 with the same resolution as Virtual-1
cmd="xrandr --addmode Virtual-2 ${width}x${height}"
echo "Executing: $cmd"
eval "$cmd"

# Set the framebuffer to accommodate both displays
cmd="xrandr --fb ${new_fb_width}x${new_fb_height} --output Virtual-1 --pos ${width}x0 --panning ${width}x${height}/${new_fb_width}x${new_fb_height}"
echo "Executing: $cmd"
eval "$cmd"

# Position Virtual-2 to the right of Virtual-1
cmd="xrandr --output Virtual-2 --mode ${width}x${height} --right-of Virtual-1"
echo "Executing: $cmd"
eval "$cmd"

echo "Virtual display setup complete!"
