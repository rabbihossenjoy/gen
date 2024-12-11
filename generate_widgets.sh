#!/bin/bash

# Check if view name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <view_name> [widget_names...]"
  exit 1
fi

# Input parameters
VIEW_NAME=$1
WIDGET_NAMES=("${@:2}") # All arguments after the view name
WIDGET_DIR="lib/views/${VIEW_NAME}/widget"
SCREEN_FILE="lib/views/${VIEW_NAME}/screen/${VIEW_NAME}_screen.dart"

# Function to convert strings like 'top_bar' to 'TopBar'
to_camel_case() {
  echo "$1" | awk -F '_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=''
}

# Create directories for widgets and screen
mkdir -p "$WIDGET_DIR"
mkdir -p "$(dirname "$SCREEN_FILE")"

# Create the main screen file with a `part` directive if not already present
if [ ! -f "$SCREEN_FILE" ]; then
  cat >"$SCREEN_FILE" <<EOL
import 'package:flutter/material.dart';

EOL
  echo "Generated $SCREEN_FILE"
fi

# Initialize a variable to store widget constructors for copying
WIDGET_CONSTRUCTORS=""

# Generate widget files with `part of` directive
for WIDGET_NAME in "${WIDGET_NAMES[@]}"; do
  WIDGET_FILE="${WIDGET_DIR}/${WIDGET_NAME}.dart"
  WIDGET_CLASS_NAME=$(to_camel_case "$WIDGET_NAME")

  # Check if file already exists to avoid overwriting
  if [ -f "$WIDGET_FILE" ]; then
    echo "File $WIDGET_FILE already exists. Skipping..."
    continue
  fi

  # Create the widget file with boilerplate code
  cat >"$WIDGET_FILE" <<EOL
part of '../screen/${VIEW_NAME}_screen.dart';

class $WIDGET_CLASS_NAME extends StatelessWidget {
  const $WIDGET_CLASS_NAME({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('$WIDGET_CLASS_NAME Widget'),
    );
  }
}
EOL

  echo "Generated $WIDGET_FILE"

  # Append the part directive to the screen file
  if ! grep -q "part '../widget/${WIDGET_NAME}.dart';" "$SCREEN_FILE"; then
    echo "part '../widget/${WIDGET_NAME}.dart';" >>"$SCREEN_FILE"
    echo "Added part directive for $WIDGET_NAME to $SCREEN_FILE"
  fi

  # Append the constructor to the clipboard string
  WIDGET_CONSTRUCTORS+="${WIDGET_CLASS_NAME}(), "
done

# Remove trailing comma and space from the constructors list
WIDGET_CONSTRUCTORS=$(echo "$WIDGET_CONSTRUCTORS" | sed 's/, $//')

# Copy widget constructors to clipboard
if command -v pbcopy &>/dev/null; then
  echo "$WIDGET_CONSTRUCTORS" | pbcopy
  echo "Copied widget constructors to clipboard using pbcopy."
elif command -v xclip &>/dev/null; then
  echo "$WIDGET_CONSTRUCTORS" | xclip -selection clipboard
  echo "Copied widget constructors to clipboard using xclip."
elif command -v xsel &>/dev/null; then
  echo "$WIDGET_CONSTRUCTORS" | xsel --clipboard --input
  echo "Copied widget constructors to clipboard using xsel."
else
  echo "Clipboard functionality not supported on this system."
  echo "Widget constructors: $WIDGET_CONSTRUCTORS"
fi
