#!/bin/bash

USERNAME=$1
PASSWORD=$2
NGROK_TOKEN=$3

echo "Setting up environment for $USERNAME"

# Disable Spotlight indexing (optional, not harmful if fails)
sudo mdutil -i off / || true
sudo mdutil -i off /System/Volumes/Data || true

# Enable Screen Sharing and Remote Management with all privileges
echo "Enabling Remote Management..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate -configure -access -on \
  -users "$USERNAME" -privs -all -restart -agent -menu

# Set VNC password securely
echo "$PASSWORD" | perl -we 'print crypt(<STDIN>, "aa")' > ~/.vncpwd
sudo defaults write /Library/Preferences/com.apple.VNCSettings.plist Password -data $(xxd -p ~/.vncpwd)

# Install and configure ngrok
brew install --cask ngrok
ngrok config add-authtoken "$NGROK_TOKEN"

# Start ngrok in background
nohup ngrok tcp 5900 > /dev/null 2>&1 &
