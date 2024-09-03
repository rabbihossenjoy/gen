#!/bin/bash

# Define paths
STRINGS_FILE="lib/languages/strings.dart"
SEARCH_DIR="lib/"
CONSTANTS_FILE="constants.txt"
UNUSED_CONSTANTS_FILE="unused_constants.txt"
TEMP_FILE="temp_strings.dart"

# Create the constants file if not already created
if [ ! -f "$CONSTANTS_FILE" ]; then
  touch "$CONSTANTS_FILE"
fi

# Extract constants from strings.dart
awk '/String\s+[A-Za-z_][A-Za-z0-9_]*\s*=/ {print $2}' "$STRINGS_FILE" > "$CONSTANTS_FILE"
sed -n 's/.*String \([A-Za-z_][A-Za-z0-9_]*\) =.*/\1/p' "$STRINGS_FILE" > "$CONSTANTS_FILE"

# Check if constants file is created and not empty
if [ ! -s "$CONSTANTS_FILE" ]; then
  echo "Error: Constants file not created or is empty."
  exit 1
fi

# Create a list to store unused constants
> "$UNUSED_CONSTANTS_FILE"

# Check each constant for usage
while IFS= read -r constant; do
  echo "Checking usage for constant: $constant"
  # Search for constant usage in the codebase
  if ! grep -r "Strings.$constant" "$SEARCH_DIR" > /dev/null; then
    echo "$constant" >> "$UNUSED_CONSTANTS_FILE"
  fi
done < "$CONSTANTS_FILE"

# Report unused constants
if [ -s "$UNUSED_CONSTANTS_FILE" ]; then
  echo "Unused constants:"
  cat "$UNUSED_CONSTANTS_FILE"
else
  echo "No unused constants found."
  exit 0
fi

# Backup the original strings.dart
cp "$STRINGS_FILE" "${STRINGS_FILE}.bak"

# Remove unused constants from strings.dart
while IFS= read -r constant; do
  echo "Removing unused constant: $constant"
  # Use sed to remove the line containing the unused constant
  sed -i.bak "/String $constant =/d" "$STRINGS_FILE"
done < "$UNUSED_CONSTANTS_FILE"

# Verify changes
echo "Updated Strings class:"
cat "$STRINGS_FILE"

echo "Removal process complete. Backup of the original file is available as ${STRINGS_FILE}.bak"

# Clean up temporary files
rm "$CONSTANTS_FILE" "$UNUSED_CONSTANTS_FILE"

# Remove the backup file after process is complete
rm "${STRINGS_FILE}.bak"

echo "Backup file removed."
