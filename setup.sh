#!/bin/bash

USERNAME="$1"
PASSWORD="$2"
NGROK_TOKEN="$3"

echo "Setting up environment for $USERNAME"

# Disable Spotlight indexing (optional; can fail without sudo)
sudo mdutil -i off /
sudo mdutil -i off /System/Volumes/Data

# Enable Remote Management (VNC) with access for specified user
echo "Enabling Remote Management..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate \
  -configure -access -on -users "$USERNAME" -privs -all \
  -restart -agent -menu

# Set VNC password
echo "$PASSWORD" | perl -we 'print crypt(<STDIN>, "aa")' > ~/.vncpwd
sudo defaults write /Library/Preferences/com.apple.VNCSettings.plist Password -data $(xxd -p ~/.vncpwd | tr -d '\n')

# Install ngrok if not installed
if ! command -v ngrok &>/dev/null; then
  echo "Installing ngrok..."
  brew install --cask ngrok
fi

# Add ngrok token and start tunnel
ngrok config add-authtoken "$NGROK_TOKEN"
ngrok tcp 5900 > /dev/null &
