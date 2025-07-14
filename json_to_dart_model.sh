#!/bin/bash

set -e

RAW_JSON="$1"
VIEW_NAME="$2"
CLASS_NAME="$3"

if [ -z "$RAW_JSON" ] || [ -z "$VIEW_NAME" ] || [ -z "$CLASS_NAME" ]; then
    echo "❌ Usage: bash json_to_dart_model.sh '<json>' view_name ClassName"
    exit 1
fi

# Convert PascalCase to snake_case
to_snake_case() {
    echo "$1" | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]'
}

# Prepare output paths
FILE_NAME="$(to_snake_case "$CLASS_NAME")"
RELATIVE_DART_FILE="views/$VIEW_NAME/model/${FILE_NAME}.dart"
ABSOLUTE_DART_FILE="$(pwd)/$RELATIVE_DART_FILE"

# Ensure output folder exists
mkdir -p "views/$VIEW_NAME/model"

# Save raw JSON into a temporary file
TMP_JSON_FILE=$(mktemp)
echo "$RAW_JSON" > "$TMP_JSON_FILE"

echo "🚀 Generating class $CLASS_NAME → $RELATIVE_DART_FILE..."

# Generate Dart model using quicktype
quicktype "$TMP_JSON_FILE" \
    --lang dart \
    --top-level "$CLASS_NAME" \
    --out "$RELATIVE_DART_FILE"

# Clean up
rm "$TMP_JSON_FILE"

# Confirm and post-process
if [ -f "$RELATIVE_DART_FILE" ]; then
    echo "✅ Model generated: $RELATIVE_DART_FILE"

    # Format with dart format
    if command -v dart &>/dev/null; then
        dart format "$RELATIVE_DART_FILE" >/dev/null
        echo "✨ Formatted with dart format"
    else
        echo "⚠️ 'dart' command not found. Skipping formatting."
    fi

    # Copy class name to clipboard (macOS only)
    if command -v pbcopy &>/dev/null; then
        echo -n "$CLASS_NAME" | pbcopy
        echo "📋 Class name '$CLASS_NAME' copied to clipboard"
    fi

    # Open the generated Dart file in VS Code
    if command -v code &>/dev/null; then
        code "$ABSOLUTE_DART_FILE"
        echo "🪟 Opened in VS Code: $ABSOLUTE_DART_FILE"
    else
        echo "⚠️ VS Code CLI 'code' not found. Run from VS Code: Command Palette → Shell Command: Install 'code'"
    fi
else
    echo "❌ Failed: Dart model not created."
fi
