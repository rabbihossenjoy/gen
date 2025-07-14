#!/bin/bash

set -e

RAW_JSON="$1"
VIEW_NAME="$2"
CLASS_NAME="$3"

if [ -z "$RAW_JSON" ] || [ -z "$VIEW_NAME" ] || [ -z "$CLASS_NAME" ]; then
    echo "❌ Usage: ./scripts/json_to_model.sh '<json>' view_name ClassName"
    exit 1
fi

cd "$(dirname "$0")/.."

# Convert PascalCase to snake_case
to_snake_case() {
    echo "$1" | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]'
}

# Prepare file paths
FILE_NAME="$(to_snake_case "$CLASS_NAME")"
RELATIVE_DART_FILE="views/$VIEW_NAME/model/${FILE_NAME}.dart"
ABSOLUTE_DART_FILE="$(pwd)/$RELATIVE_DART_FILE"

# Create model folder if not exists
mkdir -p "views/$VIEW_NAME/model"

# Save JSON input to temp file
TMP_JSON_FILE=$(mktemp)
echo "$RAW_JSON" >"$TMP_JSON_FILE"

echo "🚀 Generating class $CLASS_NAME → $RELATIVE_DART_FILE..."

# Run quicktype
quicktype "$TMP_JSON_FILE" \
    --lang dart \
    --top-level "$CLASS_NAME" \
    --out "$RELATIVE_DART_FILE"

# Clean up temp file
rm "$TMP_JSON_FILE"

# Verify file creation
if [ -f "$RELATIVE_DART_FILE" ]; then
    echo "✅ Model generated: $RELATIVE_DART_FILE"

    # ✅ Format with dart format
    dart format "$RELATIVE_DART_FILE"

    # ✅ Copy class name to clipboard (macOS)
    if command -v pbcopy &>/dev/null; then
        echo -n "$CLASS_NAME" | pbcopy
        echo "📋 Class name '$CLASS_NAME' copied to clipboard"
    fi

    # ✅ Auto-open in VS Code
    if command -v code &>/dev/null; then
        code "$ABSOLUTE_DART_FILE"
        echo "🪟 Opened in VS Code: $ABSOLUTE_DART_FILE"
    else
        echo "⚠️ VS Code CLI 'code' not found. Run from Command Palette: 'Shell Command: Install code'."
    fi
else
    echo "❌ Failed: File not created."
fi
