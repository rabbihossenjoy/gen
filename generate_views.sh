#!/bin/bash

# Define the URL of the Dart script to be downloaded
DART_SCRIPT_URL="https://raw.githubusercontent.com/rabbihossenjoy/gen/main/generate_commands.dart"

# Define the name of the local Dart file
DART_SCRIPT="generate_commands.dart"

# Check if view names are provided as arguments
if [ $# -eq 0 ]; then
    echo "Error: No view names provided. Please provide view names as arguments."
    exit 1
fi

# Download the Dart script from the URL
echo "Downloading Dart script from $DART_SCRIPT_URL..."
curl -sSL $DART_SCRIPT_URL -o $DART_SCRIPT

# Ensure the Dart script was downloaded successfully
if [ ! -f "$DART_SCRIPT" ]; then
    echo "Error: Failed to download the Dart script."
    exit 1
fi

# Verify Dart is installed
if ! command -v dart &> /dev/null; then
    echo "Error: Dart is not installed. Please install Dart and ensure it's in your PATH."
    exit 1
fi

# Check if the current user has write permissions
if [ ! -w "$(pwd)" ]; then
    echo "Error: Write permissions are required for the current directory."
    exit 1
fi

# Pass the provided view names as arguments to the Dart script
echo "Running Dart script with view names: $@"
dart run "$DART_SCRIPT" "$@"

# Check if the Dart script ran successfully
if [ $? -ne 0 ]; then
    echo "Error: Dart script execution failed."
    exit 1
fi

# Clean up the downloaded Dart script (optional)
rm -f "$DART_SCRIPT"

echo "Generation completed successfully."
