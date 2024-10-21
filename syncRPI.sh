#!/usr/bin/env sh

#!/usr/bin/env sh

# Define a list of machines
MACHINES="all simgen001.local simgen002.local simgen003.local simgen004.local"

# Prompt user to select a target using fzf
echo "Available machines: $MACHINES"
TARGET=$(echo "$MACHINES" | tr ' ' '\n' | fzf --prompt="Select target (or 'all' to sync all): ")

# Check if the user selected a target
if [ -z "$TARGET" ]; then
  echo "No target selected. Exiting."
  exit 1
fi

# Define rsync command
RSYNC_CMD="rsync -rvz -e ssh --exclude-from=.rsyncignore --delete --progress $(pwd)/ alex@"

# If 'all' is selected, iterate over all machines
if [ "$TARGET" = "all" ]; then
  echo "Syncing with all machines..."
  for machine in $MACHINES; do
    [ "$machine" = "all" ] && continue
    echo "Syncing with $machine..."
    $RSYNC_CMD"$machine:/home/alex/rpi-shaders/"
    if [ $? -eq 0 ]; then
      echo "Sync to $machine completed successfully."
    else
      echo "Sync to $machine failed."
    fi
  done
else
  # Sync with selected machine
  echo "Syncing with $TARGET..."
  $RSYNC_CMD"$TARGET:/home/alex/rpi-shaders/"
  if [ $? -eq 0 ]; then
    echo "Sync to $TARGET completed successfully."
  else
    echo "Sync to $TARGET failed."
  fi
fi

