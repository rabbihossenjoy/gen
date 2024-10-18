#!/bin/bash

# Define the URL of the Dart script
dart_script_url="https://raw.githubusercontent.com/rabbihossenjoy/gen/main/generate_multi_language.dart"

# Define the path to the strings.dart file
strings_file="lib/languages/strings.dart"

# Read the content of strings.dart
inputText=$(cat "$strings_file")

# Download the Dart script if it doesn't already exist
if [ ! -f "generate_multi_language.dart" ]; then
    echo "Downloading the Dart script..."
    curl -o generate_multi_language.dart "$dart_script_url"
else
    echo "Using existing Dart script..."
fi

# Run the downloaded Dart program with the input text
dart run generate_multi_language.dart "$inputText"

# Remove the downloaded Dart script after running
rm -f generate_multi_language.dart

echo "Temporary Dart script has been removed."
