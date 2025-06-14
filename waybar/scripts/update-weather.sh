#!/bin/bash

LOCATION="" # Insert location
OUT_FILE="/tmp/waybar-weather.json"

while true; do
    text=$(curl -s "wttr.in/${LOCATION}?format=1")
    tooltip=$(curl -s "wttr.in/${LOCATION}?format=4")

	temp=$(echo "$text" | grep -oE '[+-]?[0-9]+' || echo "0")
	text=$(echo "$text" | sed s/+//)

	if (( temp > 27 )); then
		class="hot"
	elif (( temp < 8 )); then
		class="cold"
	else
		class="mild"
	fi

    # Escape quotes to avoid breaking JSON
    text=$(echo "$text" | sed 's/["\\]/\\&/g')
    tooltip=$(echo "$tooltip" | sed 's/["\\]/\\&/g')

    printf '{ "text": "%s", "tooltip": "%s", "class": "%s" }\n' "$text" "$tooltip" "$class" > "$OUT_FILE"

    sleep 600  # Update every 10 minutes
done

