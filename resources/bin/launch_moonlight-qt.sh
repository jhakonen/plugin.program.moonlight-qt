#!/bin/bash

# Only for debugging
# set -e
#export QT_DEBUG_PLUGINS=1

. /etc/profile

cd "$(dirname "$0")"

while getopts ":a:" opt; do
  case $opt in
    a)
      ALSA_PCM_NAME="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

shift $(($OPTIND -1))
MOONLIGHT_ARGS="$@"

if [ -z "$ADDON_PROFILE_PATH" ]; then
  # If no path is given then we do a well estimated guess
  ADDON_PROFILE_PATH="$(pwd)/../../../../userdata/addon_data/plugin.program.moonlight-qt/"
fi

HOME="$ADDON_PROFILE_PATH/moonlight-home"
MOONLIGHT_PATH="$ADDON_PROFILE_PATH/moonlight-qt"

# Setup environment
export XDG_RUNTIME_DIR=/var/run/

# Fixes SDL error: Could not initialize OpenGL / GLES library
export SDL_VIDEO_GL_DRIVER=/usr/lib/libGL.so

# Do not use pulseaudio because LibreELEC only uses it for output to Bluetooth speakers
export PULSE_SERVER=none

# Make sure home path exists
mkdir -p "$HOME"

# Enter the Moonlight bin path
cd "$MOONLIGHT_PATH/bin"

# Configure audio output device
CONF_FILE="${HOME}/.config/alsa/asoundrc"
mkdir -p "$(dirname "$CONF_FILE")"
rm -f "$CONF_FILE"
if [ ! -z "$ALSA_PCM_NAME" ]; then
  echo "pcm.!default \"$ALSA_PCM_NAME\"" >> "$CONF_FILE"
fi

# Stop kodi
systemctl stop kodi

# Start moonlight-qt and log to log file
./moonlight-qt "$@" | tee "$ADDON_PROFILE_PATH/moonlight-qt.log"

# Start kodi
systemctl start kodi
