#!/bin/bash

AB=`cat /sys/class/backlight/intel_backlight/brightness`
MB=`cat /sys/class/backlight/intel_backlight/max_brightness`
echo "$AB*100/$MB" | bc -l | xargs printf "%1.0f"
