#!/bin/bash

HELD=0 # set how many packages we're holding
PML=$(pacman -Sup | wc -l)
touch /tmp/udc
UC=$(( $PML - $HELD - 1))

echo -n $UC

if (( UC > 0 ))
then
		echo " \",\"color\": \"#FFFE6A"
else
		echo " \",\"color\": \"#909090"
fi
