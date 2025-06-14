#!/bin/sh

# ┬ ┬┬┌─┐┬
# ││││├┤ │
# └┴┘┴└  ┴

# Author	Niraj
# Github	niraj998

# ┬─┐┌─┐┌─┐┬  ┌─┐┌─┐┌┐┌┌─┐┬┌─┐┌─┐
# ├┬┘│ │├┤ │  │  │ ││││├┤ ││ ┬└─┐
# ┴└─└─┘└  ┴  └─┘└─┘┘└┘└  ┴└─┘└─┘

# rofi config without entry so to make select from available options only
rofiprompt=~/.config/rofi/wifi/prompt.rasi
# normal rofi menu
rofidmenu=~/.config/rofi/wifi/dmenu.rasi
# rofi config for password
rofipass=~/.config/rofi/wifi/passwd.rasi

# ┌─┐┌┬┐┌─┐┌┬┐┬ ┬┌─┐
# └─┐ │ ├─┤ │ │ │└─┐
# └─┘ ┴ ┴ ┴ ┴ └─┘└─┘

# Power Status
flag=$(cat /sys/class/net/wl*/flags)

if [ "$flag" = "0x1003" ]; then
	power="On"
else
	power="Off"
fi

# Connection Status
state=$(cat /sys/class/net/wl*/operstate)

if [ "$state" = "up" ]; then
	status=$(nmcli device wifi | grep "^\*" | sed "s/^.[ ]*[1-9A-F\:]*[ ]*\([^ ]*\).*/Connected to \1/")
else
	status="Disconnected"
fi

# ┌─┐┌─┐┬ ┬┌─┐┬─┐
# ├─┘│ ││││├┤ ├┬┘
# ┴  └─┘└┴┘└─┘┴└─

powertoggle=$( [ "$flag" = "0x1003" ] && echo "Power Off" || echo "Power On" )

powerswitch() {
if [ "$powertoggle" = "Power Off" ]; then
	nmcli radio wifi off
elif [ "$powertoggle" = "Power On" ]; then
	nmcli radio wifi on
fi
}

# ┌─┐┌─┐┌┐┌┌┐┌┌─┐┌─┐┌┬┐
# │  │ │││││││├┤ │   │
# └─┘└─┘┘└┘┘└┘└─┘└─┘ ┴

connections() {
list=$(nmcli --fields "SECURITY,SSID" device wifi list | tail -n +2 | sed "s/  */ /g" | sed -E "s/WPA*.?//g" | sed "s/^--//g" | sed "s/ //g")
networks=$(printf "$list" | rofi -config $rofiprompt -dmenu -i -hover-select -p "Select Wifi Network
$status")
wifi=$( echo "$networks" | sed "s/ //g" | sed "s/ //g" | xargs)
[ -z "$networks" ] && exit
nopass="No Password"
pass=$(printf "$nopass\nCancel" | rofi -config $rofipass -dmenu -i -hover-select -password -p "Wifi Password")

if [ "$pass" = "" ]; then
  exit
elif [ "$pass" = "$nopass" ]; then
  nmcli dev wifi con "$wifi" && printf "exit" | rofi -config $rofiprompt -dmenu -only-match -i -p "Successfully Connected to $wifi" && exit
elif [ "$pass" = "Cancel" ]; then
  exit
else
  echo "$pass" | nmcli dev wifi con "$wifi" --ask && printf exit | rofi -config $rofiprompt -dmenu -i -only-match -p "Successfully Connected to $wifi" && exit
fi

printf "exit" | rofi -config $rofiprompt -dmenu -i -p "Failed to Connect $wifi" && exit
}


# ┌┬┐┌─┐┌┐┌┬ ┬┌─┐┬
# │││├─┤││││ │├─┤│
# ┴ ┴┴ ┴┘└┘└─┘┴ ┴┴─┘

manual() {

wifi=$(rofi -config $rofidmenu -dmenu -i -p "Enter Wifi Name")

[ -z "$wifi" ] && exit
nopass="Run Without Password"
pass=$(printf "$nopass\nCancel" | rofi -config $rofipass -dmenu -i -password -p "Wifi Password")

if [ "$pass" = "" ]; then
  exit
elif [ "$pass" = "$nopass" ]; then
  nmcli dev wifi con "$wifi" && printf "exit" | rofi -config $rofiprompt -dmenu -i -only-match -p "Successfully Connected to $wifi" && exit
elif [ "$pass" = "Cancel" ]; then
  exit
else
  echo "$pass" | nmcli dev wifi con "$wifi" --ask &&  printf "exit" | rofi -config $rofiprompt -dmenu -i -only-match -p "Successfully Connected to $wifi" && exit
fi

printf "exit" | rofi -config $rofiprompt -dmenu -only-match -i -p "Failed to Connect $wifi" && exit
}

# ┌─┐┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
# │ │├─┘ │ ││ ││││└─┐
# └─┘┴   ┴ ┴└─┘┘└┘└─┘

options="$powertoggle\nConnections\nConnect Manually"

rofiwifi=$(printf "$options" | rofi -config $rofiprompt -dmenu -i -hover-select -p "Wifi
Powered: $power
Status: $status")

case $rofiwifi in
	$powertoggle)
		powerswitch
	;;
	"Connections")
    notify-send "Scanning"
		connections
	;;
	"Connect Manually")
		manual
esac 2>/dev/null

