#!/bin/bash

set -e

# Read JSON from stdin
RAW_JSON=$(cat)
VIEW_NAME="$1"
CLASS_NAME="$2"

# Validate input
if [[ -z "$RAW_JSON" || -z "$VIEW_NAME" || -z "$CLASS_NAME" ]]; then
    echo "❌ Usage: echo '<json>' | bash json_to_dart_model.sh view_name ClassName"
    echo "   - JSON passed via stdin"
    echo "   - view_name (e.g. add_money)"
    echo "   - ClassName (e.g. AddMoneyModel)"
    exit 1
fi

# Convert PascalCase → snake_case
to_snake_case() {
    echo "$1" | sed -E 's/([a-z0-9])([A-Z])/\1_\2/g' | tr '[:upper:]' '[:lower:]'
}

# Path setup
FILE_NAME="$(to_snake_case "$CLASS_NAME")"
MODEL_DIR="views/$VIEW_NAME/model"
RELATIVE_DART_FILE="$MODEL_DIR/${FILE_NAME}.dart"
ABSOLUTE_DART_FILE="$(pwd)/$RELATIVE_DART_FILE"

mkdir -p "$MODEL_DIR"

# Save JSON to a temp file
TMP_JSON_FILE=$(mktemp)
echo "$RAW_JSON" > "$TMP_JSON_FILE"

echo "🚀 Generating Dart model: $CLASS_NAME → $RELATIVE_DART_FILE"

# Generate using quicktype
if ! command -v quicktype &>/dev/null; then
    echo "❌ quicktype CLI not found. Install it via: npm install -g quicktype"
    rm "$TMP_JSON_FILE"
    exit 1
fi

quicktype "$TMP_JSON_FILE" \
    --lang dart \
    --top-level "$CLASS_NAME" \
    --out "$RELATIVE_DART_FILE"

rm "$TMP_JSON_FILE"

# Post-process
if [[ -f "$RELATIVE_DART_FILE" ]]; then
    echo "✅ Model created at: $RELATIVE_DART_FILE"

    if command -v dart &>/dev/null; then
        dart format "$RELATIVE_DART_FILE" >/dev/null
        echo "✨ Formatted with dart format"
    else
        echo "⚠️ 'dart' CLI not found. File left unformatted."
    fi

    if command -v pbcopy &>/dev/null; then
        echo -n "$CLASS_NAME" | pbcopy
        echo "📋 Copied class name: $CLASS_NAME"
    else
        echo "ℹ️ Clipboard not updated (pbcopy not found)"
    fi

    if command -v code &>/dev/null; then
        code "$ABSOLUTE_DART_FILE"
        echo "🪟 Opened in VS Code: $ABSOLUTE_DART_FILE"
    else
        echo "⚠️ VS Code CLI 'code' not found. Run in VS Code: ⌘⇧P → 'Shell Command: Install code'"
    fi
else
    echo "❌ Failed to create Dart file"
fi
