#!/bin/bash

USERNAME=$1
PASSWORD=$2
NGROK_TOKEN=$3

echo "Setting up environment for $USERNAME"

# Disable Spotlight indexing
mdutil -i off /
mdutil -i off /System/Volumes/Data

# Start screen sharing / remote management
echo "Starting..."
echo "Setting allow all users to YES."
echo "Setting all users privileges..."

# Enable remote management and VNC access
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate -configure -access -on \
  -users "$USERNAME" -privs -all -restart -agent -menu

# Set VNC password (hashed)
echo "$PASSWORD" | perl -we 'print crypt(<STDIN>, "aa")' > ~/.vncpwd

# Set the password to ARD
sudo defaults write /Library/Preferences/com.apple.VNCSettings.plist Password -data $(xxd -p ~/.vncpwd)

# Add ngrok and start tunnel
brew install --cask ngrok
ngrok config add-authtoken "$NGROK_TOKEN"
ngrok tcp 5900 > /dev/null &
