#!/bin/sh

tmp_file="/tmp/wf_recording.pid"

if [[ -f "$tmp_file" ]]; then
    kill "$(cat "$tmp_file")"
	rm "$tmp_file"
    notify-send "Screencast Stopped"
    exit 0
fi

screenrecord() {
    videos_path="$HOME/Videos/Screencasts"
	video_name=$(date +"%d-%m-%Y-%Hu%M-recording.mp4")
	output_file="${videos_path}/${video_name}"
	if [ "$1" = 1 ]; then
		wf-recorder -g "$(slurp)" -c libx264 -f "$output_file" >/dev/null 2>&1 &
	else
		wf-recorder -c libx264 -f "$output_file" >/dev/null 2>&1 &
	fi

    echo $! > "${tmp_file}"
	notify-send "Recording started"
	exit 0
}

rofiprompt=~/.config/rofi/wifi/prompt.rasi
mode="screenshot"
region="entire screen"
while true; do
	options="Mode: $mode\nRegion: $region\nConfirm"
	rofiscreenshot=$(printf "$options" | rofi -config $rofiprompt -dmenu -i -hover-select -p "Screenshot")

	case "$rofiscreenshot" in
		"Mode: screenshot")
			mode="screencast"
			;;
		"Mode: screencast")
			mode="screenshot"
			;;
		"Region: entire screen")
			region="area"
			;;
		"Region: area")
			region="entire screen"
			;;
		"Confirm")
			break
			;;
		*)
			exit 1
			;;
	esac
done
if [ "$mode" = "screenshot" ]; then
	if [ "$region" = "area" ]; then
		grim -g "$(slurp)"
	else
		grim
	fi
else
	if [ "$region" = "area" ]; then
		screenrecord 1
	else
		screenrecord 0
	fi
fi

