#!/bin/bash

# Only for debugging
# set -e
#export QT_DEBUG_PLUGINS=1

. /etc/profile

cd "$(dirname "$0")"

if [ -z "$ADDON_PROFILE_PATH" ]; then
  # If no path is given then we do a well estimated guess
  ADDON_PROFILE_PATH="$(pwd)/../../../../userdata/addon_data/plugin.program.moonlight-qt/"
fi

HOME="$ADDON_PROFILE_PATH/moonlight-home"
MOONLIGHT_PATH="$ADDON_PROFILE_PATH/moonlight-qt"

# Do not use pulseaudio because LibreELEC only uses it for output to Bluetooth speakers
export PULSE_SERVER=none

# Make sure home path exists
mkdir -p "$HOME"

# Select output audio device
# TODO: Make configurable
mkdir -p "$HOME/.config"
echo 'defaults.pcm.!card 0;' > "${HOME}/.config/asound.conf"
echo 'defaults.pcm.!device 3;' >> "${HOME}/.config/asound.conf"

# Stop kodi
systemctl stop kodi

# Start moonlight-qt and log to log file
"$MOONLIGHT_PATH/bin/moonlight-qt" "$@" | tee "$ADDON_PROFILE_PATH/moonlight-qt.log"

# Start kodi
systemctl start kodi
