#!/bin/bash

# Scroll settings
MAX_LENGTH=35  # Adjust based on Waybar space

# Fetch player status and metadata
status=$(playerctl status 2>/dev/null)
if [[ $? -ne 0 ]]; then
    echo ""
    exit
fi

# Playback icon
case $status in
    Playing) icon=" " ;;
    Paused)  icon=" " ;;
    *)       icon="" ;;
esac

# Metadata
info=$(playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null)
info=$(echo "$info" | sed 's/["\\]/\\&/g')

if (( ${#info} > MAX_LENGTH )); then
	main_output="${icon}  ${info:0:MAX_LENGTH-2}..."
else
	main_output="${icon}  ${info}"
fi

printf '{ "text": "%s", "tooltip": "%s" }\n' "$main_output" "$info"
