#!/usr/bin/env sh

# Define a list of IP addresses (space-separated string)
MACHINES="192.168.43.250 192.168.8.127 192.168.8.128 192.168.8.129 192.168.8.117"

# Use fzf to select the target IP address
TARGET_IP=$(echo "$MACHINES" | tr ' ' '\n' | fzf --prompt="Select target IP: ")

# Check if an IP address was selected
if [ -z "$TARGET_IP" ]; then
  echo "No IP address selected. Exiting."
  exit 1
fi

# Run the rsync command with the selected IP address
rsync -rvz -e ssh --exclude-from='.rsyncignore' --progress "$(pwd)/" "alex@$TARGET_IP:/home/alex/shaders/"

# Confirm the sync was successful
if [ $? -eq 0 ]; then
  echo "Sync to $TARGET_IP completed successfully."
else
  echo "Sync to $TARGET_IP failed."
fi

