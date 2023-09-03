#!/usr/bin/env bash

set -eu

APP=$1

# Maximize app using the most commen default shortcut

osascript -e "tell application \"${APP}\"
    activate
    tell application \"System Events\"
        keystroke \"f\" using {control down, command down}
    end tell
end tell"
