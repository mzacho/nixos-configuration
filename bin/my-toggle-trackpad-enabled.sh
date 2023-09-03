#!/usr/bin/env bash

device_id=$(xinput list \
              | grep -i "touchpad" \
              | grep -o "id=[0-9]*" \
              | cut -d= -f2)

enabled=$(xinput list-props $device_id \
            | grep "Device Enabled" \
            | awk '{print $NF}')

if [ "$enabled" = "0" ]; then
    xinput enable $device_id
else
    xinput disable $device_id
fi
