#!/bin/bash

# Check if any arguments are passed, if not prompt the user for input
if [ $# -eq 0 ]; then
  echo "Please provide the view names separated by spaces (e.g., view1 view2 view3):"
  read -r -a viewsList
else
  viewsList=("$@")
fi

# Ensure that Dart and shell commands are running in the correct directory
SCRIPT_DIR=$(dirname "$0")
cd "$SCRIPT_DIR" || exit

# Ensure that the Dart and shell script have the necessary permissions
chmod +x generate_commands.dart

# Run the Dart script with the provided viewsList as arguments
dart generate_commands.dart "${viewsList[@]}"

# Navigate to the views directory and execute the generated commands
if [[ -f lib/views/commands.text ]]; then
  chmod +x lib/views/commands.text
  cd lib/views && sh commands.text
  rm -f commands.text
else
  echo "Error: commands.text file not found!"
  exit 1
fi
