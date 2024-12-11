#!/bin/bash

# Check if view name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <view_name> [widget_names...]"
  exit 1
fi

VIEW_NAME=$1
WIDGET_NAMES=("${@:2}") # All arguments after the view name
WIDGET_DIR="lib/views/${VIEW_NAME}/widget"

# Function to convert strings like 'top_bar' to 'TopBar'
to_camel_case() {
  echo "$1" | awk -F '_' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=''
}

# Create the directory for widgets
mkdir -p "$WIDGET_DIR"

# Initialize a variable to store widget constructors for copying
WIDGET_CONSTRUCTORS=""

# Generate widget files
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
import 'package:flutter/material.dart';

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

  # Append the constructor to the clipboard string
  WIDGET_CONSTRUCTORS+="${WIDGET_CLASS_NAME}(), "
done

# Remove trailing comma and space
WIDGET_CONSTRUCTORS=$(echo "$WIDGET_CONSTRUCTORS" | sed 's/, $//')

# Copy widget constructors to clipboard
echo "$WIDGET_CONSTRUCTORS" | pbcopy 2>/dev/null || xclip -selection clipboard 2>/dev/null || echo "Clipboard functionality not supported on this system."

echo "Copied widget constructors to clipboard: $WIDGET_CONSTRUCTORS"
