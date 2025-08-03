#!/bin/bash

USERNAME="$1"
PASSWORD="$2"
NGROK_TOKEN="$3"

echo "Setting up environment for user: $USERNAME"

# Disable Spotlight (ignore error if permission denied)
sudo mdutil -i off /
sudo mdutil -i off /System/Volumes/Data || true

# Enable Remote Management (VNC)
echo "Enabling Remote Management for $USERNAME..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate -configure -access -on \
  -users "$USERNAME" -privs -all -restart -agent -menu

# Set VNC password (hashed)
HASHED_PASS=$(echo "$PASSWORD" | perl -we 'print crypt(<STDIN>, "aa")')
echo "$HASHED_PASS" > ~/.vncpwd
sudo defaults write /Library/Preferences/com.apple.VNCSettings.plist Password -data $(xxd -p ~/.vncpwd | tr -d '\n')

# Install and configure ngrok
brew install --cask ngrok
ngrok config add-authtoken "$NGROK_TOKEN"

# Start ngrok tunnel
ngrok tcp 5900 > /dev/null &
