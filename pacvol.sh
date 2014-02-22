#!/bin/sh
# PulseAudio Volume Control Script
#   2010-05-20 - Gary Hetzel <garyhetzel@gmail.com>
#
#   BUG:    Currently doesn't get information for the specified sink,
#           but rather just uses the first sink it finds in list-sinks
#           Need to fix this for systems with multiple sinks
#

SINK=0
STEP=1
MAXVOL=65537 # let's just assume this is the same all over
MUTED=0
#MAXVOL=`pacmd list-sinks | grep "volume steps" | cut -d: -f2 | tr -d "[:space:]"`

MUTED=`pacmd list-sinks 0 | grep muted | cut -d ' ' -f 2`
#VOLPERC=`pactl list sinks | awk '/Volume: 0:/ {print substr($3, 1, index($3, "%") - 1)}' | head -n1`
VOLPERC=`pactl list sinks | awk '/Volume: front-left:/ {print substr($5, 1, index($5, "%") - 1)}'`
SKIPOVERCHECK=1

display(){
  if [ "$MUTED" = "yes" ]; then
    echo "🔇  muted"
  elif [ "$VOLPERC" -lt 33 ]; then
    echo "🔈  ${VOLPERC}%"
  elif [ "$VOLPERC" -lt 66 ]; then
    echo "🔉  ${VOLPERC}%"
  else
    echo "🔊  ${VOLPERC}%"
  fi
}

up(){
	VOLSTEP="$(( $VOLPERC+$STEP ))";
}

down(){
	VOLSTEP="$(( $VOLPERC-$STEP ))";
	SKIPOVERCHECK=1
}

max(){
	pacmd set-sink-volume $SINK $MAXVOL > /dev/null
}

min(){
	pacmd set-sink-volume $SINK 0 > /dev/null
}

overmax(){
	SKIPOVERCHECK=1
	if [ $VOLPERC -lt 100 ]; then
		max;
		exit 0;
	fi
	up
}

mute(){
	pacmd set-sink-mute $SINK 1 > /dev/null
}

unmute(){
	pacmd set-sink-mute $SINK 0 > /dev/null
}

toggle(){
	M=`pacmd list-sinks | grep "muted" | cut -d: -f2 | tr -d "[:space:]"`
	if [ $M == "no" ]; then
		mute;
	else
		unmute;
	fi
}

case $1 in
up)
	up;;
down)
	down;;
max)
	max
	exit 0;;
min)
	min
	exit 0;;
overmax)
	overmax;;
toggle)
	toggle
	exit 0;;
mute)
	mute;
	exit 0;;
unmute)
	unmute;
	exit 0;;
display)
	display;
	exit 0;;
*)
	echo "Usage: `basename $0` [up|down|min|max|overmax|toggle|mute|unmute|display]"
	exit 1;;
esac

VOLUME="$(( ($MAXVOL/100) * $VOLSTEP ))"

echo "$VOLUME : $OVERMAX"

 if [ -z $SKIPOVERCHECK ]; then
 	if [ $VOLUME -gt $MAXVOL ]; then
 		VOLUME=$MAXVOL
 	elif [ $VOLUME -lt 0 ]; then
 		VOLUME=0
 	fi
 fi

#echo "$VOLUME: $MAXVOL/100 * $VOLPERC+$VOLSTEP"
pacmd set-sink-volume $SINK $VOLUME > /dev/null
# VOLPERC=`pacmd list-sinks | grep "volume" | head -n1 | cut -d: -f3 | cut -d% -f1 | tr -d "[:space:]"`

#osd_cat -b percentage -P $VOLPERC --delay=1 --align=center --pos bottom --offset 50 --color=green&
