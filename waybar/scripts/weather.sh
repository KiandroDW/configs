#!/bin/bash

cat /tmp/waybar-weather.json 2>/dev/null || echo '{ "text": "⛅  ..°C", "tooltip": "Loading..." }'
